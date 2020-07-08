# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/fewest_set_features'
require 'otlearn/max_mismatch_ranking'
require 'otlearn/grammar_test'
require 'otlearn/induction_step'
require 'otlearn/data_manip'

module OTLearn
  # This performs certain inductive learning methods when contrast pair
  # learning fails to fully learn the language. The two inductive methods
  # are Max Mismatch Ranking (MMR) and Fewest Set Features (FSF).
  class InductionLearning
    # The grammar testing object.
    attr_accessor :grammar_tester

    # The Fewest Set Features learning object.
    attr_accessor :fsf_learner

    # The Max Mismatch Ranking learning object.
    attr_accessor :mmr_learner

    # Creates the induction learning object.
    # :call-seq:
    #   InductionLearning.new -> induction_learner
    #--
    # learning_module is a dependency injection used for testing.
    # * learning_module - the module containing the method
    #   #mismatch_consistency_check.
    def initialize(learning_module: OTLearn)
      @learning_module = learning_module
      @grammar_tester = GrammarTest.new
      @fsf_learner = FewestSetFeatures.new
      @mmr_learner = MaxMismatchRanking.new
      @step_type = INDUCTION
    end

    # Runs induction learning, and returns an induction learning step.
    # :call-seq:
    #   run(output_list, grammar) -> step
    def run(output_list, grammar)
      # Test the words to see which ones currently fail
      prior_result = @grammar_tester.run(output_list, grammar)
      # If there are no failed winners, raise an exception, because
      # induction learning shouldn't be called unless there are failed
      # winners to work on.
      if prior_result.failed_winners.empty?
        raise 'InductionLearning invoked with no failed winners.'
      end

      # Check failed winners for consistency, and collect the consistent ones
      consistent_list = prior_result.failed_winners.select do |word|
        @learning_module\
          .mismatch_consistency_check(grammar, [word]).consistent?
      end
      # If there are consistent failed winners, run MMR on them.
      # Otherwise, run FSF.
      if consistent_list.empty?
        substep = @fsf_learner.run(output_list, grammar, prior_result)
      else
        # extract outputs to pass to max_mismatch_ranking
        consistent_output_list = consistent_list.map do |word|
          word.output
        end
        substep = @mmr_learner.run(consistent_output_list, grammar)
      end
      changed = substep.changed?
      @test_result = @grammar_tester.run(output_list, grammar)
      InductionStep.new(substep, @test_result, changed)
    end
  end
end

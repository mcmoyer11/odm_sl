# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/consistency_checker'
require 'otlearn/grammar_test'
require 'otlearn/fewest_set_features'
require 'otlearn/max_mismatch_ranking'
require 'otlearn/otlearn'
require 'otlearn/induction_step'

module OTLearn
  # This performs certain inductive learning methods when contrast pair
  # learning fails to fully learn the language. The two inductive methods
  # are Max Mismatch Ranking (MMR) and Fewest Set Features (FSF).
  class InductionLearning
    # The object for checking consistency of words with the grammar.
    attr_accessor :consistency_checker

    # The grammar testing object.
    attr_accessor :grammar_tester

    # The Fewest Set Features learning object.
    attr_accessor :fsf_learner

    # The Max Mismatch Ranking learning object.
    attr_accessor :mmr_learner

    # Creates the induction learning object.
    # :call-seq:
    #   InductionLearning.new -> induction_learner
    def initialize
      @consistency_checker = ConsistencyChecker.new
      @grammar_tester = GrammarTest.new
      @fsf_learner = FewestSetFeatures.new
      @mmr_learner = MaxMismatchRanking.new
      @step_type = INDUCTION
    end

    # Runs induction learning, and returns an induction learning step.
    # Raises a RuntimeError if the output list does not have any failed
    # winners (winners which are not currently optimal).
    # :call-seq:
    #   run(output_list, grammar) -> step
    def run(output_list, grammar)
      # Test the winners to see which ones currently fail
      prior_result = @grammar_tester.run(output_list, grammar)
      failed_winners = prior_result.failed_winners.map(&:output)
      # If there are no failed winners, raise an exception, because
      # induction learning shouldn't be called unless there are failed
      # winners to work on.
      if failed_winners.empty?
        raise 'InductionLearning invoked with no failed winners.'
      end

      # Collect those winners that are mismatch consistent with the grammar.
      consistent_list = failed_winners.select do |output|
        @consistency_checker.mismatch_consistent?([output], grammar)
      end
      # If there are no consistent failed winners, run FSF.
      # Otherwise, run MMR.
      substep = if consistent_list.empty?
                  @fsf_learner.run(output_list, grammar, prior_result)
                else
                  @mmr_learner.run(consistent_list, grammar)
                end
      changed = substep.changed?
      @test_result = @grammar_tester.run(output_list, grammar)
      InductionStep.new(substep, @test_result, changed)
    end
  end
end

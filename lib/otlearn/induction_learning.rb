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
    # Creates the induction learning object.
    # :call-seq:
    #   InductionLearning.new -> induction_learner
    #--
    # learning_module, grammar_test_class, fewest_set_features_class,
    # and max_mismatch_ranking_class are dependency injections used
    # for testing.
    # * learning_module - the module containing the method
    #   #mismatch_consistency_check.
    # * grammar_test_class - the class of the object used to test
    #   the grammar.
    # * fewest_set_features_class - the class of object used for FSF.
    # * max_mismatch_ranking_class - the class of object used for MMR.
    def initialize(learning_module: OTLearn,
                   grammar_test_class: OTLearn::GrammarTest,
                   fewest_set_features_class: OTLearn::FewestSetFeatures,
                   max_mismatch_ranking_class: OTLearn::MaxMismatchRanking)
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @fewest_set_features_class = fewest_set_features_class
      @max_mismatch_ranking_class = max_mismatch_ranking_class
      @step_type = INDUCTION
    end

    # Runs induction learning, and returns an induction learning step.
    # :call-seq:
    #   run(output_list, grammar) -> step
    def run(output_list, grammar)
      # Test the words to see which ones currently fail
      prior_result = @grammar_test_class.new(output_list, grammar)
      # If there are no failed winners, raise an exception, because
      # induction learning shouldn't be called unless there are failed
      # winners to work on.
      if prior_result.failed_winners.empty?
        raise 'InductionLearning invoked with no failed winners.'
      end

      # Check failed winners for consistency, and collect the consistent ones
      consistent_list = prior_result.failed_winners.select do |word|
        @learning_module\
          .mismatch_consistency_check(grammar, [word]).grammar.consistent?
      end
      # If there are consistent failed winners, run MMR on them.
      # Otherwise, run FSF.
      if consistent_list.empty?
        step_subtype = FEWEST_SET_FEATURES
        # Parse the outputs into words
        winner_list = output_list.map do |out|
          grammar.parse_output(out)
        end
        substep = @fewest_set_features_class.new(winner_list, grammar,
                                                 prior_result)
      else
        step_subtype = MAX_MISMATCH_RANKING
        # extract outputs to pass to max_mismatch_ranking
        consistent_output_list = consistent_list.map do |word|
          word.output
        end
        substep = @max_mismatch_ranking_class.new(consistent_output_list,
                                                  grammar)
      end
      changed = substep.changed?
      @test_result = @grammar_test_class.new(output_list, grammar)
      InductionStep.new(step_subtype, substep, @test_result, changed)
    end
  end
end

# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/fewest_set_features'
require 'otlearn/max_mismatch_ranking'
require 'otlearn/grammar_test'
require 'otlearn/data_manip'

module OTLearn
  # This performs certain inductive learning methods when contrast pair
  # learning fails to fully learn the language. The two inductive methods
  # are Max Mismatch Ranking (MMR) and Fewest Set Features (FSF).
  class InductionLearning
    # Step subtype constant for fewest set features
    FEWEST_SET_FEATURES = :fewest_set_features

    # Step subtype constant for max mismatch learning
    MAX_MISMATCH_RANKING = :max_mismatch_ranking

    # The type of learning step
    attr_accessor :step_type

    # The subtype of induction learning step
    attr_reader :step_subtype

    # The Fewest Set Features learning step. Nil if FSF was not run.
    attr_reader :fsf_step

    # The Max Mismatch Ranking learning step. Nil if MMR was not run.
    attr_reader :mmr_step

    # Grammar test result after the completion of induction learning.
    attr_reader :test_result

    # Creates the induction learning object.
    # :call-seq:
    #   InductionLearning.new -> inductionlearner
    #--
    # learning_module, grammar_test_class, fewest_set_features_class,
    # and max_mismatch_ranking_class are dependency injections used
    # for testing.
    # * +learning_module+ - the module containing the method
    #   #mismatch_consistency_check.
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar.
    # * +fewest_set_features_class+ - the class of object used for fewest set
    #   features.
    # * +max_mismatch_ranking_class+ - the class of object used for max
    #   mismatch ranking.
    def initialize(learning_module: OTLearn,
                   grammar_test_class: OTLearn::GrammarTest,
                   fewest_set_features_class: OTLearn::FewestSetFeatures,
                   max_mismatch_ranking_class: OTLearn::MaxMismatchRanking)
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @fewest_set_features_class = fewest_set_features_class
      @max_mismatch_ranking_class = max_mismatch_ranking_class
      @changed = false
      @step_type = INDUCTION
      @step_subtype = nil
      @fsf_step = nil
      @mmr_step = nil
    end

    # Returns true if induction learning made a change to the grammar,
    # returns false otherwise.
    def changed?
      @changed
    end

    # Returns true if all words are correctly processed by the grammar;
    # returns false otherwise.
    def all_correct?
      @test_result.all_correct?
    end

    # Returns true if anything changed about the grammar
    def run(output_list, grammar)
      @output_list = output_list
      @grammar = grammar
      # Test the words to see which ones currently fail
      prior_result = @grammar_test_class.new(@output_list, @grammar)
      # If there are no failed winners, raise an exception, because
      # induction learning shouldn't be called unless there are failed
      # winners to work on.
      if prior_result.failed_winners.empty?
        raise RuntimeError.new 'InductionLearning invoked with no failed winners.'
      end

      # Check failed winners for consistency, and collect the consistent ones
      consistent_list = prior_result.failed_winners.select do |word|
        @learning_module.
          mismatch_consistency_check(@grammar, [word]).grammar.consistent?
      end
      # If there are consistent failed winners, run MMR on them.
      # Otherwise, run FSF.
      if consistent_list.empty?
        @step_subtype = FEWEST_SET_FEATURES
        # Parse the outputs into words
        winner_list = @output_list.map do |out|
          @grammar.parse_output(out)
        end
        @fsf_step = @fewest_set_features_class.new(winner_list, @grammar,
                                                   prior_result)
        @changed = @fsf_step.changed?
      else
        @step_subtype = MAX_MISMATCH_RANKING
        # extract outputs to pass to max_mismatch_ranking
        consistent_output_list = consistent_list.map do |word|
          word.output
        end
        @mmr_step = @max_mismatch_ranking_class.new(consistent_output_list,
                                                    @grammar)
        @changed = @mmr_step.changed?
      end
      @test_result = @grammar_test_class.new(@output_list, @grammar)
      @changed
    end
  end
end

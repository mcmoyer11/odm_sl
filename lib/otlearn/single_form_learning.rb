# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/single_form_step'
require 'otlearn/feature_value_learning'
require 'otlearn/paradigm_erc_learning'
require 'otlearn/grammar_test'

module OTLearn
  # This processes all of the outputs in the grammatical output list, one at a
  # time in order, with respect to a grammar. Any results of learning are
  # realized as side effect changes to the grammar.
  class SingleFormLearning
    # Paradigmatic ERC learner. Default value: ParadigmErcLearning.new
    attr_accessor :para_erc_learner

    # Feature value learner. Default value: FeatureValueLearner.new
    attr_accessor :feature_learner

    # The tester used to test the grammar.
    attr_accessor :grammar_tester

    # Creates a new single form learner.
    # :call-seq:
    #   SingleFormLearning.new -> learner
    def initialize
      # Set default values for external dependencies.
      @para_erc_learner = ParadigmErcLearning.new
      @feature_learner = FeatureValueLearning.new
      @grammar_tester = GrammarTest.new
    end

    # Runs single form learning, and returns a single form learning step.
    # :call-seq:
    #   run(output_list, grammar) -> step
    def run(output_list, grammar)
      changed = false
      loop do
        grammar_changed_on_pass = false
        output_list.each do |output|
          grammar_changed_on_winner =
            process_winner(output, output_list, grammar)
          grammar_changed_on_pass = true if grammar_changed_on_winner
        end
        changed = true if grammar_changed_on_pass
        break unless grammar_changed_on_pass
      end
      test_result = @grammar_tester.run(output_list, grammar)
      SingleFormStep.new(test_result, changed)
    end

    # Processes a winner output for new information about the grammar.
    # * Attempt to set each unset feature of the winner.
    # * For each newly set feature, check for new non-phonotactic ranking
    #   information.
    # Returns true if the grammar was changed by processing the winner,
    # false otherwise.
    def process_winner(output, output_list, grammar)
      # Attempt to set each unset feature of winner.
      winner = grammar.parse_output(output)
      set_feature_list = @feature_learner.run([winner], grammar)
      # For each newly set feature, check words unfaithfully mapping that
      # feature for new ranking information.
      set_feature_list.each do |set_f|
        @para_erc_learner.run(set_f, grammar, output_list)
      end
      # If no features were set, then the grammar did not change.
      # Otherwise, the grammar did change.
      !set_feature_list.empty?
    end
    private :process_winner
  end
end

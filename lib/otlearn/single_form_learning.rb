# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/grammar_test'
require 'otlearn/single_form_step'
require 'otlearn/paradigm_erc_learning'

module OTLearn
  # This processes all of the outputs in the grammatical output list, one at a
  # time in order, with respect to a grammar. Any results of learning are
  # realized as side effect changes to the grammar.
  class SingleFormLearning
    # Paradigmatic ERC learner. Default value: ParadigmErcLearning.new
    attr_accessor :para_erc_learner

    # Creates a new single form learner.
    #--
    # learning_module and gtest_class are dependency injections used for
    # testing.
    # * learning_module - the module containing #set_uf_values
    #++
    # :call-seq:
    #   SingleFormLearning.new -> singleformlearner
    def initialize(learning_module: OTLearn, gtest_class: GrammarTest)
      @learning_module = learning_module
      @gtest_class = gtest_class
      @para_erc_learner = ParadigmErcLearning.new
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
      test_result = @gtest_class.new(output_list, grammar)
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
      set_feature_list = @learning_module.set_uf_values([winner], grammar)
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

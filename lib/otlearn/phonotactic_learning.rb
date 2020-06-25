# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/ranking_learning'
require 'otlearn/grammar_test'
require 'otlearn/language_learning'
require 'otlearn/erc_learning'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

module OTLearn
  # Executes phonotactic learning on a list of data outputs, using the
  # provided grammar. Any effects of learning are realized as side effect
  # changes to the grammar.
  class PhonotacticLearning
    # The type of learning step
    attr_accessor :step_type

    # Grammar test result after the completion of phonotactic learning.
    attr_reader :test_result

    # The learner for additional ERCs (ranking information)
    attr_accessor :erc_learner

    # Creates the phonotactic learning object.
    # * +loser_selector+ - selects losers for ranking learning; defaults to
    #   a loser selector using CompareConsistency.
    #--
    # learning_module and grammar_test_class are dependency injections used
    # for testing.
    # * +learning_module+ - the source of the MRCD variant used.
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    #++
    #
    # :call-seq:
    #   PhonotacticLearning.new(output_list, grammar) -> phonotactic_learner
    def initialize(loser_selector: nil,
                   learning_module: OTLearn,
                   grammar_test_class: OTLearn::GrammarTest)
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @loser_selector = loser_selector
      @erc_learner = nil
      @changed = false # default value
      @step_type = PHONOTACTIC
    end

    # Returns true if phonotactic learning modified the grammar;
    # false otherwise.
    def changed?
      @changed
    end

    # Returns true if all words are correctly processed by the grammar;
    # returns false otherwise.
    def all_correct?
      @test_result.all_correct?
    end

    # Actually executes phonotactic learning.
    def run(output_list, grammar)
      @output_list = output_list
      @grammar = grammar
      # Cannot put the default in the parameter list because of the call
      # to grammar.system.
      if @loser_selector.nil?
        basic_selector = LoserSelector.new(CompareConsistency.new)
        @loser_selector = LoserSelectorFromGen.new(@grammar.system,
                                                   basic_selector)
      end
      @erc_learner ||= ErcLearning.new(@loser_selector)
      @winner_list = construct_winners
      mrcd_result =
        @learning_module.ranking_learning(@winner_list, @grammar,
                                          @loser_selector)
      @changed = true if mrcd_result.any_change?
      @test_result = @grammar_test_class.new(@output_list, @grammar)
    end

    # Parse the outputs into winners, with set input features matching their
    # lexicon values, and unset features assigned values matching the output.
    def construct_winners
      @output_list.map do |out|
        @grammar.parse_output(out).match_input_to_output!
      end
    end
    private :construct_winners
  end
end

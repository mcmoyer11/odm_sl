# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/grammar_test'
require 'otlearn/language_learning'
require 'otlearn/erc_learning'

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
    #--
    # grammar_test_class is a dependency injection used
    # for testing.
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    #++
    #
    # :call-seq:
    #   PhonotacticLearning.new -> phonotactic_learner
    def initialize(grammar_test_class: OTLearn::GrammarTest)
      @grammar_test_class = grammar_test_class
      @erc_learner = ErcLearning.new(nil)
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
      winner_list = construct_winners(output_list, grammar)
      mrcd_result = @erc_learner.run(winner_list, grammar)
      @changed = true if mrcd_result.any_change?
      @test_result = @grammar_test_class.new(output_list, grammar)
    end

    # Parse the outputs into winners, with set input features matching their
    # lexicon values, and unset features assigned values matching the output.
    def construct_winners(output_list, grammar)
      output_list.map do |out|
        grammar.parse_output(out).match_input_to_output!
      end
    end
    private :construct_winners
  end
end

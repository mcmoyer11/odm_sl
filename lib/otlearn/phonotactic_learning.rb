# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/grammar_test'
require 'otlearn/erc_learning'
require 'otlearn/phonotactic_step'

module OTLearn
  # Executes phonotactic learning on a list of data outputs, using the
  # provided grammar. Any effects of learning are realized as side effect
  # changes to the grammar.
  class PhonotacticLearning
    # The learner for additional ERCs (ranking information).
    # Default value is OTLearn::ErcLearning.new.
    attr_accessor :erc_learner

    # The grammar testing object. Default value is OTLearn::GrammarTest.new.
    attr_accessor :grammar_tester

    # Creates a phonotactic learning object.
    # :call-seq:
    #   PhonotacticLearning.new -> phonotactic_learner
    def initialize
      @grammar_tester = GrammarTest.new
      @erc_learner = ErcLearning.new
    end

    # Runs phonotactic learning, and returns a phonotactic step.
    # :call-seq:
    #   run(output_list, grammar) -> phonotactic_step
    def run(output_list, grammar)
      winner_list = construct_winners(output_list, grammar)
      mrcd_result = @erc_learner.run(winner_list, grammar)
      test_result = @grammar_tester.run(output_list, grammar)
      PhonotacticStep.new(test_result, mrcd_result.any_change?)
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

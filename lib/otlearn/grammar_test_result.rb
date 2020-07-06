# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Represents the results of an execution of GrammarTest.
  class GrammarTestResult
    # The winners that are NOT sole optima w.r.t. the included grammar.
    attr_reader :failed_winners

    # The winners that are sole optima w.r.t. the included grammar.
    attr_reader :success_winners

    # The grammar that was tested by the grammar test.
    attr_reader :grammar

    # Returns a new test result object.
    # :call-seq:
    #   GrammarTestResult.new(failed_winners, success_winners, grammar)
    #   -> result
    def initialize(failed_winners, success_winners, grammar)
      @failed_winners = failed_winners
      @success_winners = success_winners
      @grammar = grammar
    end

    # Returns true if all winners are the sole optima for their inputs
    # with all unset features set to mismatch their surface correspondents.
    def all_correct?
      @failed_winners.empty?
    end
  end
end

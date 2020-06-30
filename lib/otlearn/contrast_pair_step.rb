# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # The results of a contrast pair learning step.
  class ContrastPairStep
    # The learning step type, OTLearn::CONTRAST_PAIR.
    attr_reader :step_type

    # The result of grammar testing at the end of the learning step.
    attr_reader :test_result

    # The contrast pair constructed by the step; nil if none were found.
    attr_reader :contrast_pair

    # Returns a new step object for single form learning.
    # * test_result - the test result run at the end of the step.
    # * changed - a boolean indicating of the step changed the grammar.
    # * contrast_pair - the contrast pair resulting in new grammatical
    #   information; nil if no such contrast pair was found.
    # :call-seq:
    #   ContrastPairStep.new(test_result, changed, contrast_pair) -> step
    def initialize(test_result, changed, contrast_pair)
      @test_result = test_result
      @changed = changed
      @contrast_pair = contrast_pair
      @step_type = OTLearn::CONTRAST_PAIR
    end

    # Returns true if the grammar was changed by the learning step;
    # returns false otherwise.
    def changed?
      @changed
    end

    # Returns true if all data (words) pass grammar testing (indicating
    # that learning is complete and successful).
    def all_correct?
      @test_result.all_correct?
    end
  end
end

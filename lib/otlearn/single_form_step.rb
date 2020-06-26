# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # The results of a single form learning step.
  class SingleFormStep
    # The learning step type, OTLearn::SINGLE_FORM.
    attr_reader :step_type

    # The result of grammar testing at the end of the learning step.
    attr_reader :test_result

    # Returns a new step object for single form learning.
    # * +test_result+ - the test result run at the end of the step.
    # * +changed+ - a boolean indicating of the step changed the grammar.
    # :call-seq:
    #   SingleFormStep.new(test_result, changed) -> step
    def initialize(test_result, changed)
      @test_result = test_result
      @changed = changed
      @step_type = OTLearn::SINGLE_FORM
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

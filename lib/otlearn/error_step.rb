# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # A "learning step" that includes, at the end of a report for
  # a learning simulation, that learning terminated prematurely
  # due to an error of some sort.
  class ErrorStep
    # The type of learning step
    attr_accessor :step_type

    # The message of the error.
    attr_reader :msg

    # Returns a new error learning step, to represent the error
    # that halted language learning for a particular language.
    def initialize(msg)
      @msg = msg
      @step_type = ERROR
    end

    # Returns false, indicating that, because an error has occurred,
    # learning has failed.
    def all_correct?
      false
    end
  end
end

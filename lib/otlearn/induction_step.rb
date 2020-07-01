# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # The results of an induction learning step.
  class InductionStep
    # The learning step type, OTLearn::INDUCTION.
    attr_reader :step_type

    # The step subtype (FEWEST_SET_FEATURES or MAX_MISMATCH_RANKING)
    attr_reader :step_subtype

    # The substep learning object
    attr_reader :substep

    # The result of grammar testing at the end of the learning step.
    attr_reader :test_result

    # Returns a new step object for induction learning.
    # * step_subtype - constant indicating the induction substep type.
    # * test_result - the test result run at the end of the step.
    # * changed - a boolean indicating of the step changed the grammar.
    # :call-seq:
    #   ContrastPairStep.new(step_subtype, test_result, changed) -> step
    def initialize(step_subtype, substep, test_result, changed)
      @step_subtype = step_subtype
      @substep = substep
      @test_result = test_result
      @changed = changed
      @step_type = OTLearn::INDUCTION
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

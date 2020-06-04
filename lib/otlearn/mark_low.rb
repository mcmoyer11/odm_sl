# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Represents the class of markedness constraints. Designed to be used
  # with RankingBiasSomeLow for biased constraint demotion.
  class MarkLow
    # :call-seq:
    #   MarkLow.new -> mark_low
    def initialize; end

    # Returns true if +constraint+ is a markedness constraint,
    # false otherwise.
    def member?(constraint)
      constraint.markedness?
    end
  end
end

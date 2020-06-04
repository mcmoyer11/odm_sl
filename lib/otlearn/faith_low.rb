# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Represents the class of faithfulness constraints. Designed to be used
  # with RankingBiasSomeLow for biased constraint demotion.
  class FaithLow
    # :call-seq:
    #   FaithLow.new -> faith_low
    def initialize; end

    # Returns true if +constraint+ is a faithfulness constraint,
    # false otherwise.
    def member?(constraint)
      constraint.faithfulness?
    end
  end
end

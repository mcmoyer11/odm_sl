# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # Represents the results of a Fewest Set Features substep of
  # induction learning.
  class FsfSubstep
    # The subtype of the substep, OTLearn::FEWEST_SET_FEATURES
    attr_reader :subtype

    # The list of features newly set by FSF.
    attr_reader :newly_set_features

    # The failed winner that was used with FSF.
    attr_reader :failed_winner

    # Returns a new substep object for an Fewest Set Features substep.
    # :call-seq:
    #   #FsfSubstep.new(newly_set_features, failed_winner) -> substep
    def initialize(newly_set_features, failed_winner)
      @subtype = OTLearn::FEWEST_SET_FEATURES
      @newly_set_features = newly_set_features
      @failed_winner = failed_winner
    end

    # Returns true if FSF set at least one feature, false otherwise.
    def changed?
      !@newly_set_features.empty?
    end
  end
end

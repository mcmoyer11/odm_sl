# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Represents the results of a Max Mismatch Ranking substep of
  # induction learning.
  class MmrSubstep
    # The substep subtype MAX_MISMATCH_RANKING
    attr_reader :subtype

    # The list of ERCs newly added to the grammar by MMR.
    attr_reader :newly_added_wl_pairs

    # The failed winner that was used with MMR.
    attr_reader :failed_winner

    # Returns a new MMR substep object.
    # :call-seq:
    #   MmrSubstep.new(new_pairs, failed_winner, change_flag)
    def initialize(new_pairs, failed_winner, change_flag)
      @subtype = OTLearn::MAX_MISMATCH_RANKING
      @newly_added_wl_pairs = new_pairs
      @failed_winner = failed_winner
      @changed = change_flag
    end

    # Returns true if MMR added any ERCs, false otherwise.
    def changed?
      @changed
    end
  end
end

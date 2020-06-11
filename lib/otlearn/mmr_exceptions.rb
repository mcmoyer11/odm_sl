# frozen_string_literal: true

# Author: Morgan Moyer

# TODO: this should be contained in the module OTLearn.

# This class of exceptions holds the failed winner at issue when
# MMR learning fails.
class MMREx < RuntimeError
  # The winner that failed during MMR learning.
  attr_reader :failed_winner

  # Returns an MMREx exception object.
  def initialize(failed_winner)
    @failed_winner = failed_winner
  end
end

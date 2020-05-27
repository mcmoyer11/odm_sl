# frozen_string_literal: true

# Author: Bruce Tesar

# Selects an informative loser for the winner, if one can be found within
# the competition, relative to the provided ranking information. A loser
# is selected by calling LoserSelector#select_loser.
#
# The comparer is assumed to always respond to the method
# #more_harmonic(winner, competitor, ranking_info) with one of the following
# symbols:
# * :WINNER - the winner is more harmonic than the competitor.
# * :COMPETITOR - the competitor is more harmonic than the winner.
# * :TIE - the competitor is equally harmonic but does not have
#   identical violations.
# * :IDENT_VIOLATIONS - the competitor has an identical violation profile
#   to the winner.
class LoserSelector
  # :call-seq:
  #   LoserSelector.new(comparer) -> LoserSelector
  def initialize(comparer)
    @comparer = comparer
  end

  # Returns the first informative loser, relative to +winner+, that it
  # finds in +competition+. It searches for a loser that is informative
  # with respect to +ranking_info+ (a list of Ercs), using the candidate
  # comparison procedure in @comparer.
  # If no informative loser is found, it returns nil.
  #
  # :call-seq:
  #   select_loser(winner, competition, ranking_info) -> candidate or nil
  def select_loser(winner, competition, ranking_info)
    competition.each do |candidate|
      compare_code = @comparer.more_harmonic(winner, candidate, ranking_info)
      # If an informative loser is found, stop searching and return it.
      return candidate if compare_code == :COMPETITOR
      return candidate if compare_code == :TIE
      # A candidate with an identical violation profile cannot be informative.
      # A candidate less harmonic than the winner cannot be informative.
    end
    # If no informative loser was found, return nil.
    nil
  end
end

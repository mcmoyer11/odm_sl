# frozen_string_literal: true

# Author: Bruce Tesar

# CompareStratumCtie objects evaluate an erc with respect to a stratum
# of a constraint hierarchy, using the Ctie (conflicts tie) criterion.
# Comparisons are made via calls to #more_harmonic. The comparison is
# between the winner and the loser of the erc.
#
# Ctie, short for "conflicts tie", is a criterion that detects when
# the erc gets conflicting evaluations from the constraints in a stratum.
# The four possible return codes (implemented as symbols) represent
# the four relevant possibilities:
# * :WINNER - at least one constraint prefers the winner, and no constraints
#   prefer the loser.
# * :LOSER - at least one constraint prefers the loser, and no constraints
#   prefer the winner.
# * :CONFLICT - at least one constraint prefers the winner, and at least
#   one constraint prefers the loser.
# * :IDENT_VIOLATIONS - none of the constraints have a preference.
class CompareStratumCtie
  # Returns a new comparer.
  #
  # :call-seq:
  #   CompareStratumCtie.new -> comparer
  def initialize; end

  # Returns a code indicating how the stratum evaluates the erc, using Ctie.
  # Returns one of: :WINNER, :LOSER, :IDENT_VIOLATIONS, :CONFLICT
  # :call-seq:
  #   more_harmonic(erc, stratum) -> symbol
  def more_harmonic(erc, stratum)
    prefer_w = prefer_l = false
    stratum.each do |con|
      prefer_w = true if erc.w?(con) # set if a constraint prefers the winner
      prefer_l = true if erc.l?(con) # set if a constraint prefers the loser
    end
    return :CONFLICT if prefer_w && prefer_l
    return :WINNER if prefer_w
    return :LOSER if prefer_l

    :IDENT_VIOLATIONS
  end
end

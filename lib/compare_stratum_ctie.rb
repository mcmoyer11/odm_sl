# frozen_string_literal: true

# Author: Bruce Tesar

# CompareStratumCtie objects evaluate an erc with respect to a stratum
# of a constraint hierarchy, using the Ctie (conflicts tie) criterion.
# Comparisons are made via calls to #more_harmonic. The comparison is
# between the winner and the loser of the erc.
class CompareStratumCtie
  # Returns a new comparer.
  #
  # :call-seq:
  #   CompareStratumCtie.new -> comparer
  def initialize; end

  # Returns a code indicating how the stratum evaluates the erc, using Ctie.
  # Returns one of: :FIRST, :SECOND, :IDENT_VIOLATIONS, :CONFLICT
  def more_harmonic(erc, stratum)
    prefer_w = prefer_l = false
    stratum.each do |con|
      prefer_w = true if erc.w?(con) # set if a constraint prefers the winner
      prefer_l = true if erc.l?(con) # set if a constraint prefers the loser
    end
    return :CONFLICT if prefer_w && prefer_l
    return :FIRST if prefer_w
    return :SECOND if prefer_l

    :IDENT_VIOLATIONS
  end
end

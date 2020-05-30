# frozen_string_literal: true

# Author: Bruce Tesar

require 'win_lose_pair'

# CompareStratumCtie objects compare two candidates with respect to a stratum
# of a constraint hierarchy, using the Ctie (conflicts tie) criterion.
# Comparisons are made via calls to #more_harmonic.
class CompareStratumCtie
  # Returns a new comparer.
  #--
  # win_lose_pair_class is a dependency injection for testing.
  #++
  #
  # :call-seq:
  #   CompareStratumCtie.new -> comparer
  def initialize(win_lose_pair_class: Win_lose_pair)
    @win_lose_pair_class = win_lose_pair_class
  end

  # Returns a code indicating how the candidates compare on the stratum,
  # using Ctie.
  # Returns one of: :FIRST, :SECOND, :IDENT_VIOLATIONS, :CONFLICT
  def more_harmonic(first, second, stratum)
    wl_pair = @win_lose_pair_class.new(first, second)
    prefer1 = prefer2 = false
    stratum.each do |con|
      prefer1 = true if wl_pair.w?(con)
      prefer2 = true if wl_pair.l?(con)
    end
    return :CONFLICT if prefer1 && prefer2
    return :FIRST if prefer1
    return :SECOND if prefer2

    :IDENT_VIOLATIONS
  end
end

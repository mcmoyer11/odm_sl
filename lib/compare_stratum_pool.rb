# frozen_string_literal: true

# Author: Bruce Tesar

# CompareStratumPool objects compare candidates with respect to a stratum
# of a constraint hierarchy, using the Pool criterion.
# Comparisons are made via calls to #more_harmonic.
#
# Pool combines the constraints of a stratum and treats them like one
# aggregated constraint. Whichever candidate has the fewer total number of
# violations on the constraints of the stratum is more harmonic.
# The four possible return codes (implemented as symbols) represent
# the four relevant possibilities:
# * :FIRST - the first candidate has fewer total violations.
# * :SECOND - the second candidate has fewer total violations.
# * :TIE - the candidates have equal numbers of total violations.
class CompareStratumPool
  # Returns a new comparer.
  #
  # :call-seq:
  #   CompareStratumPool.new -> comparer
  def initialize; end

  # Returns a code indicating how the stratum evaluates the candidates.
  # Returns one of: :FIRST, :SECOND, :TIE
  # :call-seq:
  #   more_harmonic(first, second, stratum) -> symbol
  def more_harmonic(first, second, stratum)
    first_total = second_total = 0
    stratum.each do |con|
      first_total += first.get_viols(con)
      second_total += second.get_viols(con)
    end
    compare_totals(first_total, second_total)
  end

  # Compares the total number of constraint violations on the stratum
  # for the two candidates.
  # Returns one of: :FIRST, :SECOND, :TIE
  def compare_totals(first_total, second_total)
    if first_total < second_total
      :FIRST
    elsif second_total < first_total
      :SECOND
    else
      :TIE
    end
  end
  protected :compare_totals
end

# frozen_string_literal: true

# Author: Bruce Tesar

# ComparePool objects compare two candidates with respect to a constraint
# hierarchy, using the Pool criterion. At construction time,
# ComparePool is provided with a ranker, which converts a list of Ercs
# into a hierarchy. Comparisons are made via calls to #more_harmonic.
#
# Pool stands for "pooling the marks". It treats all the constraints of
# a stratum as if they were one big constraint, by summing the violation
# counts of each of the constraints in the stratum. Two candidates are
# then compared on the basis of their total stratum violations.
# The four possible return codes (implemented as symbols) represent
# the four relevant possibilities for the comparison of two candidates
# on the overall hierarchy:
# * :FIRST - the highest preferring stratum prefers the first constraint.
# * :SECOND - the highest preferring stratum prefers the second constraint.
# * :TIE - the candidates tie on all strata, despite non-identical
#   violation profiles.
# * :IDENT_VIOLATIONS - the candidates have identical violation profiles.
class ComparePool
  # Returns a new ComparePool object.
  #
  # === Parameters
  # * +ranker+ - an object which responds to #get_hierarchy(ranking_info)
  #   and returns a constraint hierarchy, consistent with ranking_info,
  #   to be used for comparing two candidates.
  #   The ranker will contain the ranking bias to be used.
  #--
  # stratum_comparer is a dependency injection used for testing.
  #++
  #
  # :call-seq:
  #   ComparePool.new(ranker) -> comparer
  def initialize(ranker, stratum_comparer: CompareStratumPool)
    @ranker = ranker
    @stratum_comparer = stratum_comparer
  end

  # Returns a code indicating how the candidates compare with
  # respect to the ranking information, using Pool.
  # Returns one of: :FIRST, :SECOND, :IDENT_VIOLATIONS, :TIE
  # :call-seq:
  #   more_harmonic(first, second, ranking_info) -> symbol
  def more_harmonic(first, second, ranking_info)
    return :IDENT_VIOLATIONS if first.ident_viols?(second)

    # generate the reference hierarchy using the ranker
    hierarchy = @ranker.get_hierarchy(ranking_info)
    # return the code for the comparison on the hierarchy
    compare_on_hierarchy(first, second, hierarchy)
  end

  # Compares the two candidates with respect to the hierarchy.
  # Returns one of: :FIRST, :SECOND, :TIE
  def compare_on_hierarchy(first, second, hierarchy)
    hierarchy.each do |stratum|
      code = @stratum_comparer.more_harmonic(first, second, stratum)
      # if candidates have an equal number of stratum violations, go to
      # the next stratum
      return code unless code == :TIE
    end
    # tying on all strata means tying on the hierarchy
    :TIE
  end
  protected :compare_on_hierarchy
end

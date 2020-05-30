# frozen_string_literal: true

# Author: Bruce Tesar

require 'compare_stratum_ctie'
require 'win_lose_pair'

# CompareCtie objects compare two candidates with respect to a constraint
# hierarchy, using the Ctie (conflicts tie) criterion. At construction time,
# a CompareCtie is provided with a ranker, which converts a list of Ercs
# into a hierarchy. Comparisons are made via calls to #more_harmonic.
class CompareCtie
  # Returns a new CompareCtie object.
  #--
  # stratum_comparer and win_loser_pair_class are dependency injections
  # used for testing.
  #++
  #
  # :call-seq:
  #   CompareCtie.new(ranker) -> comparer
  def initialize(ranker, stratum_comparer: CompareStratumCtie,
                 win_lose_pair_class: Win_lose_pair)
    @ranker = ranker
    @stratum_comparer = stratum_comparer
    @win_lose_pair_class = win_lose_pair_class
  end

  # Returns a code indicating how the candidates compare with
  # respect to the ranking information, using Ctie.
  # Returns one of: :FIRST, :SECOND, :IDENT_VIOLATIONS, :TIE
  #--
  # CompareCtie takes two candidates as parameters, rather than an erc,
  # in order to stay consistent with the general candidate comparer
  # interface, shared with classes such as CompareConsistency.
  def more_harmonic(first, second, ranking_info)
    return :IDENT_VIOLATIONS if first.ident_viols?(second)

    # adopt first as the winner, second as the loser
    erc = @win_lose_pair_class.new(first, second)
    # generate the reference hierarchy using the ranker
    hierarchy = @ranker.get_hierarchy(ranking_info)
    code = compare_on_hierarchy(erc, hierarchy)
    return :TIE if code == :CONFLICT # Ctie means conflicts tie

    code # should be either :FIRST or :SECOND
  end

  # Compares the two candidates with respect to the hierarchy.
  # Returns one of: :FIRST, :SECOND, :CONFLICT
  def compare_on_hierarchy(erc, hierarchy)
    hierarchy.each do |stratum|
      code = @stratum_comparer.more_harmonic(erc, stratum)
      return code unless code == :IDENT_VIOLATIONS
    end
    # given that this method should not be called when the candidates have
    # identical violation profiles, this point in the method should not be
    # reached.
    msg1 = 'CompareCtie#compare_on_hierarchy'
    msg2 = 'should not have a tie on all strata.'
    raise "#{msg1} #{msg2}"
  end
  protected :compare_on_hierarchy
end

# frozen_string_literal: true

# Author: Bruce Tesar

# CompareCtie objects compare two candidates with respect to a constraint
# hierarchy, using the Ctie (conflicts tie) criterion. At construction time,
# a CompareCtie is provided with a ranker, which converts a list of Ercs
# into a hierarchy. Comparisons are made via calls to #more_harmonic.
class CompareCtie
  # Returns a new CompareCtie object.
  def initialize(ranker, stratum_comparer: CompareStratumCtie)
    @ranker = ranker
    @stratum_comparer = stratum_comparer
  end

  # Returns a code indicating how the candidates compare with
  # respect to the ranking information, using Ctie.
  # Returns one of: :FIRST, :SECOND, :IDENT_VIOLATIONS, :TIE
  def more_harmonic(first, second, ranking_info)
    return :IDENT_VIOLATIONS if first.ident_viols?(second)

    hierarchy = @ranker.get_hierarchy(ranking_info)
    comp_code = compare_on_hierarchy(first, second, hierarchy)
    return :TIE if comp_code == :CONFLICT # Ctie means conflicts tie

    comp_code # should be either :FIRST or :SECOND
  end

  # Compares the two candidates with respect to the hierarchy.
  # Returns one of: :FIRST, :SECOND, :CONFLICT
  def compare_on_hierarchy(first, second, hierarchy)
    hierarchy.each do |stratum|
      eval = @stratum_comparer.compare(first, second, stratum)
      return eval unless eval == :TIE
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

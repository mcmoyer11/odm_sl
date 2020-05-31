# frozen_string_literal: true

# Author: Bruce Tesar

require 'compare_stratum_ctie'
require 'win_lose_pair'

# CompareCtie objects compare two candidates with respect to a constraint
# hierarchy, using the Ctie (conflicts tie) criterion. At construction time,
# a CompareCtie is provided with a ranker, which converts a list of Ercs
# into a hierarchy. Comparisons are made via calls to #more_harmonic.
#
# Ctie, short for "conflicts tie", is a criterion that detects when
# the candidates get conflicting evaluations from the constraints in
# the same deciding stratum. The four possible return codes (implemented
# as symbols) represent the four relevant possibilities for the comparison
# of two candidates on the overall hierarchy:
# * :FIRST - the highest stratum with a preferring constraint has a
#   first-preferring constraint and no second-preferring constraint.
# * :SECOND - the highest stratum with a preferring constraint has a
#   second-preferring constraint and no first-preferring constraint.
# * :TIE - the highest stratum with a preferring constraint has both
#   a first-preferring constraint and a second-preferring constraint.
# * :IDENT_VIOLATIONS - the candidates have identical violation profiles.
class CompareCtie
  # Returns a new CompareCtie object.
  #
  # === Parameters
  # * +ranker+ - an object which responds to #get_hierarchy(ranking_info)
  #   and returns a constraint hierarchy, consistent with ranking_info,
  #   to be used for comparing two candidates.
  #   The ranker will contain the ranking bias to be used.
  #--
  # stratum_comparer and win_loser_pair_class are dependency injections
  # used for testing.
  #++
  # :call-seq:
  #   CompareCtie.new(ranker) -> comparer
  def initialize(ranker, stratum_comparer: CompareStratumCtie.new,
                 win_lose_pair_class: Win_lose_pair)
    @ranker = ranker
    @stratum_comparer = stratum_comparer
    @win_lose_pair_class = win_lose_pair_class
  end

  # Returns a code indicating how the candidates compare with
  # respect to the ranking information, using Ctie.
  # Returns one of: :FIRST, :SECOND, :IDENT_VIOLATIONS, :TIE
  # :call-seq:
  #   more_harmonic(first, second, ranking_info) -> symbol
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
    # return the code for the comparison on the hierarchy
    compare_on_hierarchy(erc, hierarchy)
  end

  # Compares the two candidates with respect to the hierarchy.
  # Returns one of: :FIRST, :SECOND, :TIE
  def compare_on_hierarchy(erc, hierarchy)
    hierarchy.each do |stratum|
      code = @stratum_comparer.more_harmonic(erc, stratum)
      translated_code = translate_code(code)
      # if no stratum constraint has a preference, go to next stratum
      return translated_code unless translated_code == :IDENT_VIOLATIONS
    end
    # given that this method should not be called when the candidates have
    # identical violation profiles, this point in the method should not be
    # reached.
    msg1 = 'CompareCtie#compare_on_hierarchy'
    msg2 = 'should not have a tie on all strata.'
    raise "#{msg1} #{msg2}"
  end
  protected :compare_on_hierarchy

  # Translates the return codes of CompareStratumCtie#more_harmonic, which
  # are erc-oriented (:WINNER, :LOSER), to the corresponding codes for
  # CompareCtie#more_harmonic, which are symmetric-comparison-oriented
  # (:FIRST, :SECOND). A :CONFLICT on a stratum translates into a :TIE for
  # the hierarchy as a whole.
  def translate_code(code)
    case code
    when :WINNER then :FIRST
    when :LOSER then :SECOND
    when :CONFLICT then :TIE
    when :IDENT_VIOLATIONS then :IDENT_VIOLATIONS
    else
      msg1 = 'CompareCtie#translate_code:'
      msg2 = "invalid code #{code} cannot be translated."
      raise "#{msg1} #{msg2}"
    end
  end
  protected :translate_code
end

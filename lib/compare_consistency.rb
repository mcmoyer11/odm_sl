# frozen_string_literal: true

# Author: Bruce Tesar

require 'erc_list'
require 'win_lose_pair'

# Compares two candidates with respect to ranking information, to
# determine if the second candidate can be more harmonic than the first,
# consistent with the ranking information. The comparison is performed
# with a call to the method #more_harmonic.
#
# *NOTE:* this is an asymmetric comparison. The interpretation of the
# return symbols remains consistent if the provided ranking information
# is consistent.
class CompareConsistency
  # Returns a new comparer object of class CompareConsistency.
  # :call-seq:
  #   CompareConsistency.new -> comparer
  #--
  # erc_list_class and win_lose_pair_class are dependency injections,
  # used for testing.
  #++
  def initialize(erc_list_class: ErcList,
                 win_lose_pair_class: Win_lose_pair)
    @erc_list_class = erc_list_class
    @win_lose_pair_class = win_lose_pair_class
  end

  # Returns one of the following symbols:
  #
  # * :FIRST - the second candidate cannot be more harmonic than the first.
  # * :SECOND - the second candidate could be more harmonic than the first.
  # * :IDENT_VIOLATIONS - the candidates have identical violation profiles.
  def more_harmonic(first, second, ranking_info)
    # a candidate with identical violations cannot be more harmonic, but
    # the resulting trivial ERC would be consistent with any ranking
    # information.
    return :IDENT_VIOLATIONS if first.ident_viols?(second)

    # Construct an internal ErcList, and copy ranking_info into it.
    # Better than #dup: don't assume ranking_info is class ErcList.
    ercs = @erc_list_class.new.add_all(ranking_info)
    # construct a WL pair with second as the winner
    test_erc = @win_lose_pair_class.new(second, first)
    ercs.add(test_erc)
    # if the test_erc is consistent with ranking_info, the second candidate
    # is possibly more harmonic.
    return :SECOND if ercs.consistent?

    # otherwise, the second candidate is not possibly more harmonic.
    :FIRST
  end
end

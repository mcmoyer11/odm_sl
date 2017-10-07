# Author: Bruce Tesar
#

require 'rcd'
require 'most_harmonic'

# This class defines objects that select a loser for the formation of
# a winner-loser pair. Specifically, such an object does so by computing
# the optimal candidates, in the classic fashion of error-driven learning.
# The constructor is passed parameters for the linguistic system object,
# and an rcd class, which embodies rcd with some particular ranking bias.
# The default rcd class is Rcd, which has a ranking bias for all constraints
# ranked as high as possible.
# 
# Once such a selector object is created, it is used by calling the method
# #select_loser, with arguments for the intended winner and a list of ercs.
# Relative to the input of the winner, if there are 1 or more candidates
# not identical to the winner that qualify as optimal, then one of them is
# chosen as the informative loser and returned. Otherwise, nil is returned.
class LoserSelector_by_ranking
  
  # Takes a linguistic system _sys_ and a class _rcd_class_ for a variation of
  # the RCD algorithm (the ranking bias should be built into the rcd class).
  def initialize(sys, rcd_class: Rcd, optimizer_class: MostHarmonic)
    @system = sys
    @rcd_class = rcd_class
    @optimizer_class = optimizer_class
  end

  # Looks for an informative loser to pair with _winner_, relative to the
  # ranking information provided in _erc_list_.
  #
  # The input of _winner_ is run through _GEN_, and the resulting set of
  # candidates is evaluated with respect to the constraint hierarchy resulting
  # from the application of the class's rcd_class to the _erc_list_. Returns
  # an informative loser if one is found among the optima, and returns nil
  # otherwise.
  def select_loser(winner, erc_list)
    # Generate all candidates for the input of the winner.
    competition = @system.gen(winner.input)
    # find the most harmonic candidates
    hierarchy = @rcd_class.new(erc_list).hierarchy
    mh = @optimizer_class.new(competition, hierarchy)
    # select an appropriate most harmonic candidate (if any) to be the loser
    loser = mh.find do |cand|
      if cand.ident_viols?(winner) then
        false # don't select a loser with identical violations
      elsif mh.more_harmonic?(winner, cand, hierarchy)
        false # don't select a loser that is already less harmonic
      else
        true
      end
    end
    return loser
  end
end # class LoserSelector_by_ranking

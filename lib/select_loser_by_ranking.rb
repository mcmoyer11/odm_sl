# Author: Bruce Tesar
#

require 'most_harmonic'

class Select_loser_by_ranking
  def initialize(winner,sys,hypothesis,rcd_class)
    @winner = winner
    @system = sys
    @erc_list = hypothesis.erc_list
    @rcd_class = rcd_class
    @optimizer_class = MostHarmonic
  end
  
  def set_optimizer(optimizer_class)
    @optimizer_class = optimizer_class
  end
   
  def select_loser
    # Generate all candidates for the input of the winner.
    competition = @system.gen(@winner.input)
    # find the most harmonic candidates
    hierarchy = @rcd_class.new(@erc_list).hierarchy
    mh = @optimizer_class.new(competition, hierarchy)
    # select an appropriate most harmonic candidate (if any) to be the loser
    loser = mh.find do |cand|
      if cand.ident_viols?(@winner) then
        false # don't select a loser with identical violations
      elsif mh.more_harmonic?(@winner, cand, hierarchy)
        false # don't select a loser that is already less harmonic
      else
        true
      end
    end
    return loser
  end
end # class Select_loser_by_ranking

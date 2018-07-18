# Author: Bruce Tesar

require 'erc_list'
require 'win_lose_pair'

# An object for selecting a loser in pursuit of ranking information.
# The Exhaustive criterion means that it will check every candidate of
# the competition until it either finds an informative loser or verifies that
# there are none.
# The competition is obtained by calling GEN with the input of the winner.
#
# The object is used by calling #select_loser, with a +winner+ and an
# +ranking_info+, where +ranking_info+ contains existing ranking information.
# An informative loser is one that is more harmonic than the winner
# for at least one ranking consistent with the ranking information in
# +erc_list+.
class LoserSelectorExhaustive
  # Returns a new LoserSelectorExhaustive object, initialized with the
  # linguistic system object +system+.
  # +system+ provides access to GEN for the system.
  def initialize(system,
      erc_list_class: Erc_list, win_lose_pair_class: Win_lose_pair)
    @system = system
    @erc_list_class = erc_list_class
    @win_lose_pair_class = win_lose_pair_class
  end
  
  # Returns an informative loser if one is found, otherwise returns nil.
  # The candidates are searched in the order of the list returned by GEN,
  # and the method returns as soon as the first informative loser is found.
  def select_loser(winner, ranking_info)
    # Construct an internal Erc_list, and copy ranking_info into it.
    # This way, we don't need to assume ranking_info is of class Erc_list.
    internal_ercs = @erc_list_class.new
    ranking_info.each {|erc| internal_ercs.add(erc)}
    # Generate the competition, and iterate over the competitors
    competition = @system.gen(winner.input)
    competition.each do |cand|
      # a candidate with an identical violation profile won't be informative
      unless cand.ident_viols?(winner)
        # Construct a negated WL-pair, with cand as the winner,
        # and winner as the loser
        test_erc = @win_lose_pair_class.new(cand, winner)
        # Add WL-pair to a duplicate internal erc list
        ercs = internal_ercs.dup
        ercs.add(test_erc)
        # if the test_erc is consistent with the existing ercs,
        # then the candidate is an informative loser
        return cand if ercs.consistent?
      end
    end
    return nil
  end
  
end # class LoserSelectorExhaustive

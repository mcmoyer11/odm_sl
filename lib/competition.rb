# Author: Bruce Tesar

require 'win_lose_pair'
require 'erc_list'

# Stores the candidates of a competition (i.e., candidates
# that have the same input).
class Competition < Array

  # Returns an empty competition.
  #
  # :call-seq:
  #   Competition.new() -> Competition
  #--
  # The default winner-loser pair class is Win_lose_pair. The +wl_pair_class+
  # parameter is primarily for testing purposes (dependency injection).
  def initialize(wl_pair_class: Win_lose_pair, erc_list_class: Erc_list)
    @wl_pair_class = wl_pair_class
    @erc_list_class = erc_list_class
  end
  
  # Returns an Erc_list of winner-loser pairs for the competition.
  # 
  # Raises a RuntimeError if no candidate is indicated as an optimum.
  # Raises a RuntimeError if multiple candidates are indicated as optima.
  def winner_loser_pairs
    # Make sure there is exactly one candidate marked optimum to use as the winner.
    winner_list = winners
    if (winner_list.size < 1)
      raise "Competition: cannot cannot generate winner-loser pairs without an indicated optimum."
    end
    if (winner_list.size > 1)
      raise "Competition: cannot have more than one candidate indicated as an optimum."
    end
    winner = winner_list.first
    # Construct a list of winner-loser pairs, one per loser
    wl_list = @erc_list_class.new
    losers.each do |loser|
      pair = @wl_pair_class.new(winner,loser)      
      wl_list.add(pair)
    end
    return wl_list
  end

  # Returns true if at least one candidate is marked as optimal;
  # false otherwise.
  def optima?
    (find_all{|c| c.opt?}).size > 0
  end

  # Returns a list of the candidates marked as optimal.
  def winners
    find_all{|c| c.opt?}
  end

  # Returns a list of the candidates marked as not optimal.
  def losers
    find_all{|c| !c.opt?}
  end

  # Returns a reference to the constraint list of the candidates. Returns
  # an empty array if the competition is empty (contains no candidates).
  #--
  # The idea is to have a single constraint list object shared by all other
  # objects in the system (more efficient).
  #++
  def constraint_list
    return [] if empty?
    return self[0].constraint_list
  end

  # Returns a reference to an instance of the input for the competition
  # (all candidates in a competition should have the same input).
  # Returns nil if the competition is empty (contains no candidates).
  #--
  # Simply returns a reference to the input of the first candidate in the list.
  #++
  def input
    return nil if empty?
    return self[0].input
  end

  # Directly modifies the competition so that equivalent candidates have been merged.
  # Each set of equivalent candidates is merged together: the first
  # candidate is duplicated (leaving the original unaffected),
  # and the other violation-matching candidates are added to the duplicate
  # as merge candidates. The merged duplicate is then added back
  # to the original competition (the original candidates have been removed).
  # Returns a reference to the receiving competition (self).
  def merge_identical_candidates!
    nonmatch = self.dup
    self.clear
    while !nonmatch.empty? do
      match, nonmatch = nonmatch.partition{|cand| nonmatch.first.ident_viols?(cand)}
      merge_cand = match.shift.dup # remove first candidate, duplicate it.
      match.each {|c| merge_cand.add_merge_candidate(c)} # merge the matching candidates.
      self << merge_cand
    end
    self
  end

  # Returns a competition in which equivalent candidates have been merged.
  # Candidates are equivalent if they have identical violation profiles.
  # Each set of equivalent candidates is merged together: the first
  # candidate is duplicated (leaving the original unaffected),
  # and the other violation-matching candidates are added to the duplicate
  # as merge candidates. The merged duplicate is then added to the returned
  # competition.
  def merge_identical_candidates
    new_comp = Competition.new
    nonmatch = self.dup
    while !nonmatch.empty? do
      match, nonmatch = nonmatch.partition{|cand| nonmatch.first.ident_viols?(cand)}
      merge_cand = match.shift.dup # remove first candidate, duplicate it.
      match.each {|c| merge_cand.add_merge_candidate(c)} # merge the matching candidates.
      new_comp << merge_cand
    end
    return new_comp
  end

  # Returns a string consisting of the to_s() for each candidate, separated
  # by newlines, and terminated by a newline.
  def to_s
    "#{join("\n")}\n"
  end

end # class Competition

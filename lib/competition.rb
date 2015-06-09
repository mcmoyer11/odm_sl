# Author: Bruce Tesar
#

# Stores the candidates of a competition (i.e., candidates
# that have the same input).
class Competition < Array

  # Returns an empty competition.
  def initialize
  end

  # Returns true if at least one candidate is marked as optimal;
  # false otherwise.
  def optima?
    (find_all{|c| c.opt?}).size > 0
  end

  # Returns true if more than one candidate is marked as optimal;
  # false otherwise.
  def mult_optima?
    (find_all{|c| c.opt?}).size > 1
  end

  # Returns true if exactly one candidate is marked as optimal;
  # false otherwise.
  def sing_optimum?
    (find_all{|c| c.opt?}).size == 1
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

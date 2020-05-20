# Author: Bruce Tesar

# Stores the candidates of a competition (i.e., candidates
# that have the same input).
class Competition < Array

  # Returns an empty competition.
  #
  # :call-seq:
  #   Competition.new() -> Competition
  def initialize; end

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

  # Returns a string consisting of the to_s() for each candidate, separated
  # by newlines, and terminated by a newline.
  def to_s
    "#{join("\n")}\n"
  end

end # class Competition

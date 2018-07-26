# Author: Bruce Tesar
#

# Stores a list of competitions comprising a dataset. 
class Competition_list < Array
  # A label for the competition list; defaults to "NoLabel".
  attr_accessor :label
  
  # Constructs an empty list, with label _label_.
  def initialize(label = "NoLabel")
    @label = label
  end

  # Returns a list of the constraints.
  def constraint_list
    return [] if empty?
    return self[0].constraint_list    
  end

  # Searches for duplicate inputs among the competitions in the list.
  # Returns an array containing each input that appears in more than
  # one competition. Returns an empty array if there are no duplicate inputs.
  def find_duplicate_inputs
    inputs = {}  # hash mapping each input to a list of the competitions containing it.
    self.each{|c| (inputs[c.input] ||= []) << c}
    dup_pairs = inputs.find_all{|input, list| list.size > 1}
    return dup_pairs.map{|p| p[0]}
  end

  # Returns true if every competition in the list has exactly one
  # candidate labeled as optimal; false otherwise.
  def single_opt_per_competition?
    return self.all?{|c| c.sing_optimum?}
  end

  # Calls Competition#merge_identical_candidates!() for each competition in
  # the list, thus merging (within each competition) candidates with
  # identical violation profiles.
  def merge_identical_candidates!
    self.each{|comp| comp.merge_identical_candidates!}
  end

  # Returns a competition list where, within each competition, candidates
  # with identical violation profiles have been merged.
  def merge_identical_candidates
    new_comp_list = Competition_list.new(self.label)
    merged_competitions = self.map{|comp| comp.merge_identical_candidates}
    return new_comp_list.concat(merged_competitions)
  end

end # class Competition_list

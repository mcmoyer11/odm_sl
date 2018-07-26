# Author: Bruce Tesar

# Stores a list of competitions comprising a dataset. 
class CompetitionList < Array
  # A label for the competition list
  attr_accessor :label
  
  # Constructs an empty list, with label _label_.
  def initialize()
    @label = ""
  end

  # Returns a list of the constraints.
  def constraint_list
    return [] if empty?
    return self[0].constraint_list    
  end

end # class CompetitionList

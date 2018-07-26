# Author: Bruce Tesar

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

end # class Competition_list

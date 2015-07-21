# Author: Bruce Tesar

require_relative 'input'

# Generates input objects of class Input.
class Input_factory
  def initialize
    
  end
  
  # Returns a new object of class Input.
  def new_input
    Input.new
  end
end

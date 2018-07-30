# Author: Bruce Tesar

# An IO correspondence relation contains input-output correspondence
# pairs.
#
# NOTE: a correspondence is specific to a particular instance of
# a particular structural description. References to the actual
# elements of the input and output are stored in the correspondence,
# and retrieval is based on object identity, using .equal?(), NOT ==.
# This is important: two phonologically identical elements could have
# separate existence in the same input or output (and even belong to
# the same morpheme).
#---
# Each pair is a size 2 array with the first element the input
# correspondent and the second element the output correspondent.
class IOCorrespondence < Array

  # The index in a correspondence pair for the input element.
  IN = 0
  
  # The index in a correspondence pair for the output element.
  OUT = 1
  
  # Returns an empty IOCorrespondence.
  def initialize
  end
  
  # Adds a correspondence pair indicating that +in_el+ and +out_el+
  # are IO correspondents. Returns a reference to the IO correspondence itself.
  def add_corr(in_el,out_el)
    pair = []
    pair[IN] = in_el
    pair[OUT] = out_el
    self << pair
    return self
  end

  # Returns true if the output element _out_ has an input correspondent.
  def in_corr?(out)
    any?{|pair| pair[OUT].equal?(out)}    
  end
  
  # Returns true if the input element _input_ has an output correspondent.
  def out_corr?(input)
    any?{|pair| pair[IN].equal?(input)}
  end

  # Returns the input correspondent for output element _out_. If _out_ has
  # no input correspondent, nil is returned. If _out_ has more than one
  # input correspondent, the first one listed in the correspondence
  # relation is returned.
  def in_corr(out)
    first_pair = find{|pair| pair[OUT].equal?(out)}
    return nil if first_pair.nil?
    return first_pair[IN]
  end
  
  # Returns the output correspondent for input element _input_. If _input_ has
  # no output correspondent, nil is returned. If _input_ has more than one
  # output correspondent, the first one listed in the correspondence
  # relation is returned.
  def out_corr(input)
    first_pair = find{|pair| pair[IN].equal?(input)}
    return nil if first_pair.nil?
    return first_pair[OUT]
  end

end # class IOCorrespondence

# Author: Bruce Tesar

# An IO correspondence relates corresponding input-output elements.
#
# NOTE: an IO correspondence is specific to a particular instance of
# a particular word. References to the actual
# elements of the input and output are stored in the correspondence,
# and retrieval is based on object identity, using .equal?(), NOT ==.
# This is important: two phonologically identical elements could have
# separate existence in the same input or output (and even belong to
# the same morpheme).
#---
# Each pair is a size 2 array with the first element the input
# correspondent and the second element the output correspondent.
class IOCorrespondence

  # The index in a correspondence pair for the input element.
  IN = 0
  
  # The index in a correspondence pair for the output element.
  OUT = 1
  
  # Returns an empty IOCorrespondence.
  def initialize
    @pair_list = []
  end
  
  # Adds a correspondence pair indicating that +in_el+ and +out_el+
  # are IO correspondents. Returns a reference to the IO correspondence itself.
  def add_corr(in_el,out_el)
    pair = []
    pair[IN] = in_el
    pair[OUT] = out_el
    @pair_list << pair
    return self
  end
  
  # Returns true if the correspondence relation contains no pairs;
  # returns false otherwise.
  def empty?
    @pair_list.empty?
  end

  # Returns true if the output element +out_el+ has an input correspondent.
  def in_corr?(out_el)
    @pair_list.any?{|pair| pair[OUT].equal?(out_el)}    
  end
  
  # Returns true if the input element +in_el+ has an output correspondent.
  def out_corr?(in_el)
    @pair_list.any?{|pair| pair[IN].equal?(in_el)}
  end

  # Returns the input correspondent for output element _out_. If _out_ has
  # no input correspondent, nil is returned. If _out_ has more than one
  # input correspondent, the first one listed in the correspondence
  # relation is returned.
  def in_corr(out)
    first_pair = @pair_list.find{|pair| pair[OUT].equal?(out)}
    return nil if first_pair.nil?
    return first_pair[IN]
  end
  
  # Returns the output correspondent for input element +in_el+. If +in_el+ has
  # no output correspondent, nil is returned. If +in_el+ has more than one
  # output correspondent, the first one listed in the correspondence
  # relation is returned.
  def out_corr(in_el)
    first_pair = @pair_list.find{|pair| pair[IN].equal?(in_el)}
    return nil if first_pair.nil?
    return first_pair[OUT]
  end

end # class IOCorrespondence

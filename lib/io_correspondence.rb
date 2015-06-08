# Author: Bruce Tesar
#

# An IO correspondence relation contains input-output correspondence
# pairs, each pair a size 2 array with the first element the input
# correspondent and the second element the output correspondent.
#
# NOTE: a correspondence is specific to a particular instance of
# a particular structural description. References to the actual
# elements of the input and output are stored in the correspondence,
# and retrieval is based on object identity, using .equal?(), NOT ==.
# This is important: two phonologically identical elements could have
# separate existence in the same input or output (and even belong to
# the same morpheme).
class IOCorrespondence < Array

  # Returns an empty IOCorrespondence.
  def initialize
  end

  # Returns true if the output element _out_ has an input correspondent.
  def in_corr?(out)
    any?{|pair| pair[1].equal?(out)}    
  end
  
  # Returns true if the input element _input_ has an output correspondent.
  def out_corr?(input)
    any?{|pair| pair[0].equal?(input)}
  end

  # Returns the input correspondent for output element _out_. If _out_ has
  # no input correspondent, nil is returned. If _out_ has more than one
  # input correspondent, the first one listed in the correspondence
  # relation is returned.
  def in_corr(out)
    first_pair = find{|pair| pair[1].equal?(out)}
    return nil if first_pair.nil?
    return first_pair[0]
  end
  
  # Returns the output correspondent for input element _input_. If _input_ has
  # no output correspondent, nil is returned. If _input_ has more than one
  # output correspondent, the first one listed in the correspondence
  # relation is returned.
  def out_corr(input)
    first_pair = find{|pair| pair[0].equal?(input)}
    return nil if first_pair.nil?
    return first_pair[1]
  end

end # class IOCorrespondence

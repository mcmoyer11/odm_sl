# Author: Bruce Tesar
#

# A UI correspondence relation contains underlying-input correspondence
# pairs, each pair a size 2 array with the first element the underlying
# correspondent and the second element the input correspondent.
# A separate UICorrespondence exists for every input; it realizes
# the relation between the input and the lexical entries of its morphemes,
# at the level of individual correspondence elements.
class UICorrespondence < Array

  # Returns an empty UICorrespondence.
  def initialize    
  end

  # Returns true if underlying element _under_ has an input
  # correspondent. Returns false otherwise.
  def in_corr?(under)
    any?{|pair| pair[0].equal?(under)}    
  end
  
  # Returns true if input element _input_ has an underlying
  # correspondent (in the lexicon). Returns false otherwise.
  def under_corr?(input)
    any?{|pair| pair[1].equal?(input)}
  end

  # Returns the input correspondent for underlying element _under_.
  # If _under_ has no input correspondent, then nil is returned.
  # 
  # If _under_ has more than one correspondent, the first one listed
  # in the correspondence relation (unpredictable) is returned. *Note*:
  # if multiple correspondence is allowed, a different implementation
  # of the correspondence relation should be used.
  def in_corr(under)
    first_pair = find{|pair| pair[0].equal?(under)}
    return nil if first_pair.nil?
    return first_pair[1]
  end
  
  # Returns the underlying correspondent for input element _input_.
  # If _input_ has no underlying correspondent, then nil is returned.
  #
  # If _input_ has more than one correspondent, the first one listed
  # in the correspondence relation (unpredictable) is returned. *Note*:
  # if multiple correspondence is allowed, a different implementation
  # of the correspondence relation should be used.
  def under_corr(input)
    first_pair = find{|pair| pair[1].equal?(input)}
    return nil if first_pair.nil?
    return first_pair[0]
  end

end # class UICorrespondence

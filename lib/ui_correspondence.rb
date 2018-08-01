# Author: Bruce Tesar

# A UI correspondence relates corresponding underlying-input elements.
# The underlying elements belong to the lexical entries of the morphemes
# for the input.
# 
# NOTE: a UI correspondence is specific to a particular instance of
# a particular input. References to the actual
# elements of the underlying form and input are stored in the correspondence,
# and retrieval is based on object identity, using .equal?(), NOT ==.
# This is important: two phonologically identical elements could have
# separate existence in the same input (and even belong to
# the same morpheme).
#---
# Each pair is a size 2 array with the first element the underlying
# correspondent and the second element the input correspondent.
class UICorrespondence

  # The index in a correspondence pair for the underlying element.
  UF = 0
  
  # The index in a correspondence pair for the input element.
  IN = 1
  
  # Returns an empty UICorrespondence.
  def initialize
    @pair_list = []
  end

  # Adds a correspondence pair indicating that +uf_el+ and +in_el+
  # are UI correspondents. Returns a reference to the UI correspondence itself.
  def add_corr(uf_el,in_el)
    pair = []
    pair[UF] = uf_el
    pair[IN] = in_el
    @pair_list << pair
    return self
  end
  
  # Returns the number of correspondence pairs in the relation.
  def size
    @pair_list.size
  end
  
  # TODO: modernize the system_spec.rb files, so this method can be eliminated.
  def [](idx)
    @pair_list[idx]
  end
  
  # Returns true if underlying element +uf_el+ has an input
  # correspondent. Returns false otherwise.
  def in_corr?(uf_el)
    @pair_list.any?{|pair| pair[UF].equal?(uf_el)}    
  end
  
  # Returns true if input element +in_el+ has an underlying
  # correspondent (in the lexicon). Returns false otherwise.
  def under_corr?(in_el)
    @pair_list.any?{|pair| pair[IN].equal?(in_el)}
  end

  # Returns the input correspondent for underlying element +uf_el+.
  # If +uf_el+ has no input correspondent, then nil is returned.
  # 
  # If +uf_el+ has more than one correspondent, the first one listed
  # in the correspondence relation (unpredictable) is returned. *Note*:
  # if multiple correspondence is allowed, a different implementation
  # of the correspondence relation should be used.
  def in_corr(uf_el)
    first_pair = @pair_list.find{|pair| pair[UF].equal?(uf_el)}
    return nil if first_pair.nil?
    return first_pair[IN]
  end
  
  # Returns the underlying correspondent for input element +in_el+.
  # If +in_el+ has no underlying correspondent, then nil is returned.
  #
  # If +in_el+ has more than one correspondent, the first one listed
  # in the correspondence relation (unpredictable) is returned. *Note*:
  # if multiple correspondence is allowed, a different implementation
  # of the correspondence relation should be used.
  def under_corr(in_el)
    first_pair = @pair_list.find{|pair| pair[IN].equal?(in_el)}
    return nil if first_pair.nil?
    return first_pair[UF]
  end

end # class UICorrespondence

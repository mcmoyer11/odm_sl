# Author: Bruce Tesar
#

# An Erc_list is a list of ERC-like objects. All ercs in the list must respond
# to #constraint_list with a list of the very same constraints.
class Erc_list
  
  # Returns an empty Erc_list.
  def initialize
    @list = []
  end
  
  # Adds +erc+ to the list.
  # Returns the Erc_list.
  def add(erc)
    # check that the new erc uses exactly the same constraints as the
    # existing ercs in the list.
    unless empty? then # if this is the first erc, nothing to check
      unless erc.constraint_list.size == constraint_list.size then
        raise "Erc_list#add: cannot add an erc with a different number of constraints"
      end
      unless erc.constraint_list.all?{|con| constraint_list.include?(con)} then
        raise "Erc_list#add: cannot add an erc with different constraints"
      end
    end
    # append the new erc to the list, and return self (the Erc_list).
    @list << erc
    self
  end
  
  # Returns true if the list is empty; returns false otherwise.
  def empty?
    @list.empty?
  end
  
  # Returns the number of ERCs in the list.
  def size
    @list.size
  end
  
  # Returns true if any of the elements of the list satisfy the block.
  # Returns false otherwise.
  def any? &block
    @list.any?(&block)
  end
  
  # Returns an list of the constraints used in the ERCs.
  def constraint_list
    return [] if @list.empty?
    @list[0].constraint_list
  end
end # class Erc_list

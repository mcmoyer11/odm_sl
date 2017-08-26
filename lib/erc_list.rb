# Author: Bruce Tesar
#

# An Erc_list is a list of ERC-like objects. All ercs in the list must respond
# to #constraint_list with a list of the very same constraints.
# ---
# === Delegated Methods
# [empty?] Returns true if the list is empty, false otherwise.
# [size] Returns the integer number of ERCs in the list.
# [any?] Returns true if any of the ERCs satisfies the block, false otherwise.
# [each] Applies the block to each member of the list.
class Erc_list
  extend Forwardable
  
  def_delegators :@list, :empty?, :size, :any?, :each
    
  # Returns an empty Erc_list.
  def initialize
    @list = []
  end
  
  # Adds +erc+ to self.
  # +erc+ must respond to #constraint_list.
  # Returns a reference to self.
  # 
  # Raises a RuntimeError if +erc+ does not have exactly the same constraints
  # as the existing ERCs of the list.
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
  
  # Adds all ERCs of +list+ to self.
  # +list+ must respond to #each.
  # Returns a reference to self.
  # 
  # Raises a RuntimeError if any of the ERCS in +list+ does not have exactly
  # the same constraints as the existing ERCs of the list (or each other).
  def add_all(list)
    list.each {|e| add(e)}
    self
  end
  
  # Returns an Erc_list containing all ercs that <em>satisfy</em> the block.
  def find_all(&block)
    satisfies = @list.find_all(&block)
    new_el = Erc_list.new
    satisfies.each {|e| new_el.add(e)}
    new_el
  end
  
  # Returns an Erc_list containing all ercs that <em>do not satisfy</em> the block.
  def reject(&block)
    not_satisfies = @list.reject(&block)
    new_el = Erc_list.new
    not_satisfies.each{|e| new_el.add(e)}
    new_el
  end
  
  # Returns an array containing the ercs of the erc list.
  def to_a
    ary = []
    @list.each{|e| ary.push(e)}
    ary
  end
  
  # Returns a list of the constraints used in the ERCs.
  def constraint_list
    return [] if @list.empty?
    @list[0].constraint_list
  end
end # class Erc_list

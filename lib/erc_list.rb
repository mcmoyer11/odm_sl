# Author: Bruce Tesar
#

# An Erc_list is a list of ERC-like objects. All ERCs in the list must respond
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
    # check that the new ERC uses exactly the same constraints as the
    # existing ERCs in the list.
    unless empty? then # if this is the first ERC, nothing to check
      unless erc.constraint_list.size == constraint_list.size then
        raise "Erc_list#add: cannot add an ERC with a different number of constraints"
      end
      unless erc.constraint_list.all?{|con| constraint_list.include?(con)} then
        raise "Erc_list#add: cannot add an ERC with different constraints"
      end
    end
    # append the new ERC to the list, and return self (the Erc_list).
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
  
  # Returns an Erc_list containing all ERCs for which the block
  # returns <em>true</em>.
  #
  # :call-seq:
  #   find_all{|obj| block} -> Erc_list
  def find_all(&block)
    satisfies = @list.find_all(&block)
    new_el = Erc_list.new
    satisfies.each {|e| new_el.add(e)}
    new_el
  end
  
  # Returns an Erc_list containing all ERCs for which the block
  # returns <em>false</em>.
  #
  # :call-seq:
  #   reject{|obj| block} -> Erc_list
  def reject(&block)
    not_satisfies = @list.reject(&block)
    new_el = Erc_list.new
    not_satisfies.each{|e| new_el.add(e)}
    new_el
  end
  
  # Partitions the members of the ERC list based on whether they satisfy
  # the provided block. Returns two Erc_list objects, the first containing
  # the ERCs for which the block returns true, and the second containing
  # those for which the block returns false.
  #
  # :call-seq:
  #   partition{|obj| block} -> [true-Erc_list, false-Erc_list]
  def partition(&block)
    true_list, false_list = @list.partition(&block)
    return Erc_list.new.add_all(true_list), Erc_list.new.add_all(false_list)
  end
  
  # Returns an array containing the ERCs of the ERC list.
  def to_a
    ary = []
    @list.each{|e| ary.push(e)}
    ary
  end
  
  # Returns a duplicate Erc_list with an independent list, meaning that
  # adding or removing ERCs from the duplicate will not affect the original.
  # The ERC objects themselves are <em>not</em> duplicated.
  def dup
    Erc_list.new.add_all(self)
  end
  
  # Returns a list of the constraints used in the ERCs.
  def constraint_list
    return [] if @list.empty?
    @list[0].constraint_list
  end
end # class Erc_list

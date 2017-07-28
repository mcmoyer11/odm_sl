# Author: Bruce Tesar
# 
#--
# Represent the erc with a set of constraints assigning W, and
# a set of constraints assigning L. Constraints not in either
# list assign e. This makes it possible
# to efficiently determine things like the ERC arrow operator
# and fusion via subset methods.

# An Elementary Ranking Condition (ERC). Given a set of constraints,
# each constraint is assigned one of three values:
# W:: prefers the winner
# L:: prefers the loser
# e:: no preference
#
# Newly constructed ERCs assign 'e' to all constraints; other
# values must be assigned via the set methods.
class Erc

  # Returns the set of W-preferring constraints.
  attr_reader :w_cons
  # Returns the set of L-preferring constraints.
  attr_reader :l_cons

  # Constructs a new ERC (initialized to 'e' for every constraint).
  # +constraints+ is a list of the constraint objects.
  def initialize(constraints, label="NoLabel")
    @constraints = constraints
    @label = label
    @w_cons = Set.new
    @l_cons = Set.new
  end
  
  # Returns a copy with a its own copy of the preferences.
  def dup
    copy = super
    # Set the preference objects of the copy to be duplicates
    # of the preference objects of the current.
    copy.instance_variable_set(:@w_cons,@w_cons.dup)
    copy.instance_variable_set(:@l_cons,@l_cons.dup)
    return copy
  end
  
  # Returns true if +con+ prefers the winner; false otherwise.
  def w?(con)
    @w_cons.include?(con)
  end

  # Returns true if +con+ prefers the loser; false otherwise.
  def l?(con)
    @l_cons.include?(con)
  end

  # Returns true if +con+ has no preference; false otherwise.
  def e?(con)
    !@w_cons.include?(con) and !@l_cons.include?(con)
  end
  
  # Sets +con+ to prefer the winner.
  def set_w(con)
    @l_cons.delete(con)
    @w_cons.add(con)
  end

  # Sets +con+ to prefer the loser.
  def set_l(con) 
    @w_cons.delete(con)
    @l_cons.add(con)
  end

  # Sets +con+ to have no preference.
  def set_e(con)
    @w_cons.delete(con)
    @l_cons.delete(con)
  end

  # returns true if +other+ has identical preferences to this ERC.
  # The labels are ignored.
  def eql?(other)
    (@w_cons==other.w_cons) and (@l_cons==other.l_cons)
  end

  # The same as eql?().
  def ==(other)
    eql?(other)
  end

  # Returns true if the erc is trivially valid.
  # 
  # An erc is trivially valid if it has no L-preferring constraints.
  def triv_valid?
    @l_cons.empty?
  end

  # Returns true if the erc is trivially invalid.
  #
  # An erc is trivially invalid if it has no W-preferring constraints
  # and at least one L-preferring constraint.
  def triv_invalid?
    @w_cons.empty? and !@l_cons.empty?
  end

  # Returns a hash value for the ERC, such that ERCs with identical
  # constraint preferences will receive the same hash value.
  #--
  # The hash value is based only on the hash values of the Sets
  # containing the W- and L-preferring constraints. Set#hash() values
  # for two Sets are equal if the sets are equivalent.
  # The bits of the hash value for @w_cons are left-shifted 1 bit,
  # and that result is combined with the hash value for @l_cons via
  # bit-wise EXCLUSIVE OR.
  def hash
    (@w_cons.hash << 1) ^ (@l_cons.hash)
  end

  # Returns the ERC's list of constraints.
  def constraint_list
    @constraints
  end

  # Returns the label of the ERC.
  def label() @label end

  # Sets the label of the ERC to +lab+. Returns the label.
  def label=(lab) @label = lab end
  
  # Returns a string representation of +con+'s preference (W,L,or e).
  def pref_to_s(con)
    if w?(con) then return "W"
    elsif l?(con) then return "L"
    else return "e"
    end
  end

  # Convert only the constraint preference values to a string.
  # Useful for representing the prefs separately from the label.
  def prefs_to_s
    prefs_s = ""
    @constraints.each{|c| prefs_s += " #{c}:#{pref_to_s(c)}"}
    prefs_s.lstrip!  # remove the leading space from the string
    "#{prefs_s}"    
  end
  
  # A string representation of the label and the constraint preferences.
  def to_s
    "#{@label} #{prefs_to_s}"
  end

  # Expands the erc with respect to the constraints preferring the loser,
  # returning an array of ercs.
  # For each L-preferring constraint, a separate erc is constructed, preserving
  # all W's, and changing all but the selected L-preferring constraint to e.
  # If none of the constraints prefers the loser (or only one),
  # the returned array contains only the original erc itself.
  def conjunctive_expansion
    return [self] if l_cons.size < 2
    expansion = []
    l_cons.each do |lcon_ref|
      new_erc = self.dup
      l_cons.each do |c|
        new_erc.set_e(c) unless c==lcon_ref
      end
      expansion << new_erc
    end
    return expansion
  end

  # Returns an Erc list in which each erc of +erc_list+ has been
  # conjunctively expanded, so each resulting ERC contains at most one L.
  def Erc.conj_expand_list(erc_list)
    expanded_list = []
    erc_list.each {|erc| expanded_list.concat(erc.conjunctive_expansion)}
    return expanded_list
  end

end # class Erc

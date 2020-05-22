# frozen_string_literal: true

# Author: Bruce Tesar

require 'forwardable'
require_relative 'rcd'
require_relative 'win_lose_pair'

# An ErcList is a list of ERC-like objects. All ERCs in the list must respond
# to #constraint_list with a list of the very same constraints.
# ---
# === Methods delegated to object of class Array
# #empty?, #size, #any?, #each, #each_with_index
class ErcList
  extend Forwardable

  # Methods delegated to object (@list) of class Array.
  def_delegators :@list, :empty?, :size, :any?, :each, :each_with_index

  # An optional label. Defaults to the empty string "".
  attr_accessor :label

  # Returns an empty ErcList. It can optionally be passed a list of
  # constraints. If a constraint list is not provided at object construction,
  # then the constraints of the first ERC added will determine
  # the constraint list.
  #
  # Providing a list of constraints at construction time:
  # * Allows added ERCs to be checked to make sure their constraints match.
  # * Makes it easy to apply RCD to an empty ErcList.
  #
  # :call-seq:
  #   ErcList.new() -> ErcList
  #   ErcList.new(constraint_list: my_constraints) -> ErcList
  #--
  # The default RCD class is Rcd. The +rcd_class+ parameter is
  # primarily for testing purposes (dependency injection).
  def initialize(constraint_list: nil, rcd_class: Rcd)
    @list = []
    @constraint_list = constraint_list
    @rcd_class = rcd_class
    @label = ''
    # consistency is initially unknown (RCD has not been run).
    @consistency_test = nil
  end

  # Creates an Erc list containing winner-loser pairs with the +winner+ and
  # each loser of the +competition+.
  #
  # :call-seq:
  #   ErcList.new_from_competition(winner, competition) -> ErcList
  #--
  # The +wlpair_class+ is a dependency injection for testing.
  def self.new_from_competition(winner, competition,
                                wlpair_class: Win_lose_pair)
    wl_list = new
    # Exclude the winner from the list of loser candidates
    losers = competition.reject { |candidate| candidate == winner }
    # Create a new winner-loser pair for each loser
    losers.each do |loser|
      pair = wlpair_class.new(winner, loser)
      wl_list.add(pair)
    end
    wl_list
  end

  # Adds +erc+ to self.
  # +erc+ must respond to #constraint_list.
  # Returns a reference to self.
  #
  # Raises a RuntimeError if +erc+ does not have exactly the same constraints
  # as used in the list.
  def add(erc)
    # check that the new ERC uses exactly the same constraints used in the list.
    # if constraints haven't been provided, then nothing to check
    unless constraint_list.empty?
      unless erc.constraint_list.size == constraint_list.size
        raise 'ErcList#add: cannot add an ERC with a different number of constraints'
      end
      unless erc.constraint_list.all? { |con| constraint_list.include?(con) }
        raise 'ErcList#add: cannot add an ERC with different constraints'
      end
    end
    # append the new ERC to the list, and return self (the ErcList).
    @list << erc
    # program has not yet checked if the new erc is consistent
    @consistency_test = nil
    self
  end

  # Adds all ERCs of +list+ to self.
  # +list+ must respond to #each.
  # Returns a reference to self.
  #
  # Raises a RuntimeError if any of the ERCS in +list+ does not have exactly
  # the same constraints as used in the list.
  def add_all(list)
    list.each { |e| add(e) }
    self
  end

  # Returns an ErcList containing all ERCs for which the block
  # returns <em>true</em>.
  #
  # :call-seq:
  #   find_all{|obj| block} -> ErcList
  def find_all(&block)
    satisfies = @list.find_all(&block)
    new_el = ErcList.new
    satisfies.each { |e| new_el.add(e) }
    new_el
  end

  # Returns an ErcList containing all ERCs for which the block
  # returns <em>false</em>.
  #
  # :call-seq:
  #   reject{|obj| block} -> ErcList
  def reject(&block)
    not_satisfies = @list.reject(&block)
    new_el = ErcList.new
    not_satisfies.each { |e| new_el.add(e) }
    new_el
  end

  # Partitions the members of the ERC list based on whether they satisfy
  # the provided block. Returns two ErcList objects, the first containing
  # the ERCs for which the block returns true, and the second containing
  # those for which the block returns false.
  #
  # :call-seq:
  #   partition{|obj| block} -> [true-ErcList, false-ErcList]
  def partition(&block)
    true_list, false_list = @list.partition(&block)
    [ErcList.new.add_all(true_list), ErcList.new.add_all(false_list)]
  end

  # Returns an array containing the ERCs of the ERC list.
  def to_a
    ary = []
    @list.each { |e| ary.push(e) }
    ary
  end

  # Returns an array containing the ERCs of the ERC list. #to_ary is called on
  # an object whenever the Ruby interpreter needs a parameter passed to
  # a method to be an array, such as when an ErcList is compared to an array
  # for content equivalence using Array#==. The conversion method #to_a
  # produces the same output, but is called by Ruby (and users) in other
  # circumstances. These conventions are built into Ruby's standard library;
  # see the Pickaxe book for 1.9 & 2.0, section 23.3 "Standard Protocols and
  # Conversions".
  def to_ary
    to_a
  end

  # Returns a duplicate ErcList with an independent list, meaning that
  # adding or removing ERCs from the duplicate will not affect the original.
  # The ERC objects themselves are <em>not</em> duplicated.
  def dup
    ErcList.new(constraint_list: @constraint_list, rcd_class: @rcd_class) \
           .add_all(self)
  end

  # Returns a list of the constraints used in the list. If no constraints were
  # provided to the constructor, and no ERCs have been added, then an empty
  # array is returned.
  def constraint_list
    return @constraint_list unless @constraint_list.nil?
    return [] if @list.empty?

    @constraint_list = @list[0].constraint_list
  end

  # Returns true if the list of ERCs is consistent; false otherwise.
  #--
  # If consistency status is currently unknown, calculates and stores it
  # with a new Rcd_class object.
  def consistent?
    @consistency_test = @rcd_class.new(self) if @consistency_test.nil?
    @consistency_test.consistent?
  end
end

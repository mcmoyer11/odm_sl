# Author: Bruce Tesar
#

# Need to load the standard library Set before modifying it.
require 'set'

# Temporarily turn off warnings, to surpress the two warnings about
# redefined methods (eql? and hash) in Set.
verbose_val = $VERBOSE
$VERBOSE = false

# This is an addition to the standard library class Set.
#
# It compensates for a shortcoming in the Ruby implementation (including 1.8.6).
# The class Set is based on (contains an instance of, not a subclass) class Hash.
# Hash does not implement the methods hash() and eql?(), so they default
# to the versions defined in class Object. As a consequence, two hashes are
# eql only if they are the same object, normally, and the hash() values
# assigned to them are equal only if they are the same object. The class Set
# also does not implement hash() and eql?(), and inherits this odd behavior.
# Interestingly, Hash does implement the == operator, and does so by testing
# whether two hashes have the same key/value pairs, the behavior one would
# normally expect. The == operator also behaves appropriately for Set.
#
# The implementations provided here for Set remedy the shortcomings of the
# implementations in Object.
# The method eql?() simply calls the == operator.
# The method hash() returns a value based on the hash values of the members
# of the set, in a way that is insensitive to order of recall from the set.
# Thus, any set with equivalent members will have the same hash value.
class Set
  
  # The same as Set#==(). Returns true if two sets are equivalent, that is,
  # if they contain the same elements.
  def eql?(o)
    self==(o)
  end

  # Returns a hash value for a set such that equivalent sets receive
  # the same hash value.
  #--
  # A Set contains a hash, with a key for every set member mapped to the
  # value true. This method makes a list of the keys of the hash, finds
  # the hash value for each member, and takes the bitwise exclusive OR
  # of all of the hash values. Bitwise exclusive OR is commutative, so
  # it will yield the same value for the same set of numbers no matter
  # what order. This method was created by Bruce Tesar, and is patterned
  # after the hash() method for class Array (in the Ruby source code).
  #
  # The instance variable @hash is the hash object for an instance of Set.
  def hash
    @hash.keys.inject(0) {|h,key| h ^= key.hash}
  end
  
end # class Set

# Reset the value of $VERBOSE to what is was.
# Normally, this should turn warnings back on.
$VERBOSE = verbose_val

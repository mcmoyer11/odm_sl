# Author: Bruce Tesar
#

# An underlying form is the phonological representation associated with
# a morpheme, in the form of a list of correpondence elements.
class Underlying < Array

  # Returns an empty Underlying object.
  def initialize
  end

  # Returns a copy of the underlying form, containing a copy of
  # each of the correspondence elements of the original.
  def dup
    copy = Underlying.new
    self.each{|el| copy << el.dup}
    return copy
  end

  # String form is the concatenation of the string form of each
  # element in the underlying form (with no separating symbols).
  def to_s
    self.join
  end
end # class Underlying

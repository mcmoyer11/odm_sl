# Author: Bruce Tesar
#

# An Output is a list of correspondence elements, with an associated
# morphological word.
class Output < Array

  # A newly created output is empty, with no morphological word, so that
  # it can be built up piece by piece.
  def initialize
    @morphword = nil
  end

  # Returns a reference to the output's morphological word.
  def morphword
    @morphword
  end

  # Sets the output's morphological word to the parameter _mw_.
  def morphword=(mw)
    @morphword = mw
  end

  # Returns a copy of the output, containing a duplicate of each
  # correspondence element and a duplicate of the morphological word.
  def dup
    # Call Array#map to get an array of dups of the elements, and add
    # them to a new Output.
    copy = Output.new.concat(super.map { |el| el.dup })
    copy.morphword = @morphword.dup unless @morphword.nil?
    return copy
  end
 
  # Two outputs are the same if they contain equivalent elements.
  # The morphological words are *not* checked for equality.
  def ==(other)
    return false unless super
    true
  end

  # Equivalent to ==().
  def eql?(other)
    self==other
  end

  # Returns a string containing the #to_s() of each element in the output.
  def to_s
    self.join
  end
  
end # class Output

# Author: Bruce Tesar
#

require_relative 'morpheme'
require_relative 'underlying'

# A lexical entry pairs a morpheme with an underlying form.
class Lexical_Entry
  attr_reader :morpheme

  # Returns a lexical entry with the given morpheme and underlying form.
  def initialize(morph=Morpheme.new, uf=Underlying.new)
    @morpheme = morph
    @underlying_form = uf
  end
  
  # The morpheme object is identical in the copy entry, but a duplicate
  # is made of the underlying form for the copy entry.
  def dup
    return Lexical_Entry.new(@morpheme, @underlying_form.dup)
  end

  # Returns the label of the morpheme in this lexical entry.
  def label
    @morpheme.label
  end

  # Returns the morphological type of the morpheme in this lexical entry.
  def type
    @morpheme.type
  end

  # Returns the underlying form of the morpheme in this lexical entry.
  def uf
    @underlying_form
  end

  # Returns a string giving the morpheme label and the underlying form.
  def to_s
    "#{@morpheme.label} #{@underlying_form.to_s}"
  end

end # class Lexical_Entry

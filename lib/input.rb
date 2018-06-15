# Author: Bruce Tesar
#

require 'REXML/syncenumerator'
require_relative 'morph_word'
require_relative 'ui_correspondence'

# An ordered list of syllables, and a correspondence relation between those
# syllables and their correspondents in the lexicon. An input is typically
# formed by concatenating the underlying forms of the morphemes of
# a lexical word.
class Input < Array
  # the morphword associated with the input
  attr_accessor :morphword
  
  # the UI (underlying <-> input) correspondence
  attr_accessor :ui_corr

  # Creates a new input, with an empty morphological word, and an empty
  # underlying-input (UI) correspondence relation.
  def initialize
    @morphword = MorphWord.new
    @ui_corr = UICorrespondence.new
  end

  # Makes a duplicate copy of each syllable when duplicating the input,
  # and makes an appropriately adjusted UI correspondence as well (containing
  # the duplicated syllables). The morphword is also duplicated.
  def dup
    copy = Input.new # contents of copy are filled in below
    copy.morphword = @morphword.dup unless @morphword.nil?
    copy.ui_corr = UICorrespondence.new
    self.each do |old_syl|
      new_syl = old_syl.dup # duplicate the old syllable
      copy << new_syl # add the dup to the copy
      # get the corresponding underlying syllable in the original's UI correspondence.
      # If it exists, add a correspondence to the copy between this underlying
      # syllable and the duplicated input syllable in the copy.
      under_syl = @ui_corr.under_corr(old_syl)
      copy.ui_corr << [under_syl,new_syl] unless under_syl.nil?
    end
    return copy
  end

  # Two inputs are the same if they contain equivalent syllables.
  def ==(other)
    return false unless super
    true
  end

  # the same as ==(_other_).
  def eql?(other)
    self==other
  end
  
  # Lists the syllables of the input as a string, with dashes between morphemes.
  def to_s
    morph = first.morpheme
    out_str = ""
    self.each do |syl|
      unless syl.morpheme==morph then # a new morpheme has been reached
        out_str += '-'
        morph = syl.morpheme
      end
      out_str += syl.to_s
    end
    return out_str
  end

  def to_gv
    morph = first.morpheme
    out_str = ""
    self.each do |syl|
#      unless syl.morpheme==morph then # a new morpheme has been reached
#        out_str += ' '
#        morph = syl.morpheme
#      end
      out_str += syl.to_gv
    end
    return out_str
  end
  
end # class Input

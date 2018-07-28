# Author: Bruce Tesar

require_relative 'sheet'

# Formats the contents of a lexicon into text in a 2-dimensional sheet.
#
# This class delegates many methods to a Sheet object.
# 
# Given a lexicon of one prefix (a), three roots (p,q,r) and
# two suffixes (y.z):
#
# | p1 | a |  |    |   |  |    |   |
# | r1 | p |  | r2 | q |  | r3 | r |
# | s1 | y |  | s2 | z |  |    |   |
class LexiconImage
  
  # Constructs a new lexicon image from a +lexicon+.
  # 
  # * +lexicon+ - a lexicon of roots, prefixes, and suffixes.
  #
  # :call-seq:
  #   LexiconImage.new(lexicon) -> img
  def initialize(lexicon)
    @sheet = Sheet.new
    @last_row = 0
    add_morphs(lexicon.get_prefixes) unless lexicon.get_prefixes.empty?
    add_morphs(lexicon.get_roots) unless lexicon.get_roots.empty?
    add_morphs(lexicon.get_suffixes) unless lexicon.get_suffixes.empty?
  end
  
  # Delegate all method calls not explicitly defined here to the sheet object.
  def method_missing(name, *args, &block)
    @sheet.send(name, *args, &block)
  end
  protected :method_missing
  
  # Takes a list of morphemes and creates an image of a row listing out
  # the entries for the morphemes. Each entry takes two consecutive cells:
  # first the label of the morpheme, then the underlying form.
  # For rows with more than one entry, a blank cell occurs between adjacent
  # entries.
  # 
  # The row image is then added to the bottom of the lexicon image sheet,
  # with no blank rows.
  def add_morphs(mlist)
    morph_image = Sheet.new
    last_col = 0 # Sheet col. indexing starts from 1, so adding on from index 0.
    mlist.each do |m|
      morph_image[1,last_col+1] = m.label
      morph_image[1,last_col+2] = m.uf
      last_col += 3 # the next entry will skip a cell, if it is created.
    end
    # add to the bottom of the lex image.
    @last_row += 1
    @sheet.put_range[@last_row,1] = morph_image
  end
  protected :add_morphs

end # class LexiconImage

# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'

# Formats the contents of a lexicon into text in a 2-dimensional sheet.
#
# Given a lexicon of one prefix (a), three roots (p,q,r) and
# two suffixes (y.z):
#
# | p1 | a |  |    |   |  |    |   |
# | r1 | p |  | r2 | q |  | r3 | r |
# | s1 | y |  | s2 | z |  |    |   |
class LexiconImageMaker
  # Returns a new lexicon image maker.
  #--
  # +sheet_class+ is a dependency injection used for testing.
  #++
  # :call-seq:
  #   LexiconImageMaker.new -> image_maker
  def initialize(sheet_class: Sheet)
    @sheet_class = sheet_class
  end

  # Returns a sheet with an image of +lexicon+.
  # :call-seq:
  #   get_image(lexicon) -> sheet
  def get_image(lexicon)
    @sheet = @sheet_class.new
    @last_row = 0
    add_morphs(lexicon.get_prefixes) unless lexicon.get_prefixes.empty?
    add_morphs(lexicon.get_roots) unless lexicon.get_roots.empty?
    add_morphs(lexicon.get_suffixes) unless lexicon.get_suffixes.empty?
    @sheet
  end

  # Takes a list of morphemes and creates an image of a row listing out
  # the entries for the morphemes. Each entry takes two consecutive cells:
  # first the label of the morpheme, then the underlying form.
  # For rows with more than one entry, a blank cell occurs between adjacent
  # entries.
  # The row image is then added to the bottom of the lexicon image sheet,
  # with no blank rows.
  def add_morphs(mlist)
    morph_image = @sheet_class.new
    last_col = 0 # Sheet col. indexing starts from 1, so adding on from index 0.
    mlist.each do |m|
      morph_image[1, last_col + 1] = m.label
      morph_image[1, last_col + 2] = m.uf
      last_col += 3 # the next entry will skip a cell, if it is created.
    end
    # add to the bottom of the lex image.
    @last_row += 1
    @sheet.put_range[@last_row, 1] = morph_image
  end
  private :add_morphs
end

# Author: Bruce Tesar
#

# A MorphWord represents the morphological structure of a word.
# It contains the morphemes of the word in order.
# 
# Although a MorphWord need not be constructed with a root, the first
# morpheme added to the word must be a root, and a word can only have
# one root. The order of the morphemes presumes that the word is put
# together from the inside out: the first prefix added will immediately
# precede the root, the second prefix added will appear immediately before
# that, etc., with the beginning of the word consisting of the last prefix
# added (unless no prefixes are added). Similarly, the first suffix added
# appears immediately after the root, and so forth, with the end of the word
# consisting of the last suffix added (unless no suffixes are added).
class MorphWord
  include Enumerable

  # Returns a new morphological word. If a root is provided as a parameter,
  # it is added as the root of the word. Otherwise, the word is initially
  # empty. A RuntimeError exception is raised if the constructor is given
  # a morpheme that is not a root.
  def initialize(root=nil)
    @word = []
    if root.nil? then
      @root_added = false
    elsif root.root? then
      @word.push(root)
      @root_added = true
    else
      raise "MorphWord.initialize: The first morpheme added to a MorphWord must be a root."
    end
  end

  # Returns the number of morphemes in the word.
  def morph_count
    @word.size
  end
  
  # Adds the morpheme _morph_ to the word. The morpheme must be an accepted
  # morpheme type (root, prefix, suffix). An exception is raised if an attempt
  # is made to add a root to word already containing a root, or a non-root to
  # a word that does not already contain a root.
  def add(morph)
    if morph.root? then
      raise "Cannot add a second root to a morphological word." if @root_added
      @word.push(morph)
      @root_added = true
    elsif !@root_added then
      raise "Cannot add an affix to a morphological word without a root."
    elsif morph.prefix? then
      @word.unshift(morph)
    elsif morph.suffix? then
      @word.push(morph)
    else
      raise "A morph_word only accepts valid morpheme types."
    end
  end

  # Applies the given code block to each morpheme in the word in order of
  # precedence (left to right).
  def each
    @word.each{|m| yield(m)}
  end
  
  # dup() copies the @root_added value, and creates a duplicate @word array
  # filled with the same morpheme objects (which should be unique).
  def dup
    copy = MorphWord.new
    copy.word = @word.dup
    copy.root_added = @root_added
    return copy
  end

  # Returns true if the two morph_words consist of equivalent
  # morphemes in the identical sequence.
  def ==(other_word)
    # Must have the same quantity of morphemes
    return false unless self.morph_count == other_word.morph_count
    # Get external iterators over the morphemes of the words.
    # SyncEnumerator won't work here, because it requires []-style access.
    self_iter = self.to_enum
    other_iter = other_word.to_enum
    # Iterate over both morph_words simultaneously
    loop do
      self_morph = self_iter.next
      other_morph = other_iter.next
      # Order-matching morphemes must be the same
      return false unless self_morph == other_morph
    end
    return true
  end

  # A synonym for ==.
  def eql?(other_word)
    self==other_word
  end

  # Sets the root_added flag to the parameter _boolean_.
  # Protected: used in #dup.
  def root_added=(boolean)
    @root_added = boolean
  end

  # Sets the word array to the parameter _w_.
  # Protected: used in #dup.
  def word=(w)
    @word = w
  end
  protected :root_added=, :word=

  def to_s
    (@word.map{|m| m.label}).join('-')
  end

end # class MorphWord

# Author: Bruce Tesar

require_relative 'morph_word'
require_relative 'ui_correspondence'
require_relative 'feature_instance'

# An ordered list of elements, and a correspondence relation between those
# elements and their correspondents in the lexicon. An input is typically
# formed by concatenating the underlying forms of the morphemes of
# a lexical word.
class Input
  # the morphword associated with the input
  attr_accessor :morphword
  
  # the UI (underlying <-> input) correspondence
  attr_accessor :ui_corr

  # Creates a new input, with a morphological word and an
  # underlying-input (UI) correspondence relation.
  def initialize(morphword: MorphWord.new, ui_corr: UICorrespondence.new,
      feature_instance_class: FeatureInstance)
    @morphword = morphword
    @ui_corr = ui_corr
    @feature_instance_class = feature_instance_class
    @element_list = []
  end

  # Delegate all method calls not explicitly defined here to the element list.
  def method_missing(name, *args, &block)
    @element_list.send(name, *args, &block)
  end
  protected :method_missing

  # Returns a duplicate of the input. This is a deep copy, containing
  # a duplicate of the morphword and a duplicate of each input element.
  # The copy's UI correspondence is between the duplicate input elements and
  # the very same underlying elements of the lexicon.
  def dup
    # Create an empty input for the copy. The morphword is set to nil in
    # the constructor call to avoid generation of a new Morphword object,
    # since the morphword field will be overwritten with a duplicate
    # of self's morphword.
    # The copy has an empty UI correspondence relation, which will have pairs
    # added to it that match the UI pairs of self.
    copy = Input.new(morphword: nil)
    copy.morphword = @morphword.dup
    # For each element of self, create a duplicate element and add it to
    # the copy. Then add a corresponding UI pair for the duplicate element,
    # if such a pair exists in self.
    self.each do |old_el|
      new_el = old_el.dup
      copy << new_el
      # Get the corresponding underlying element in self's UI correspondence.
      under_el = @ui_corr.under_corr(old_el)
      # If a corresponding underlying element exists, add a correspondence
      # between the underlying element and the copy's input element.
      copy.ui_corr.add_corr(under_el,new_el) unless under_el.nil?
    end
    return copy
  end

  # Returns true if self and other contain equivalent (==) elements.
  # Returns false otherwise.
  # 
  # NOTE: does not check for equivalence of morphwords. To require that
  # as well, use Input#eql?().
  def ==(other)
    return false unless self.size == other.size
    self.each_index {|idx| return false unless self[idx] == other[idx]}
    return true
  end

  # Returns true of self and other contain equivalent (==) elements *and*
  # equivalent (==) morphwords.
  # The morphword equivalence requirement distinguishes Input#eql?() from 
  # Input#==().
  def eql?(other)
    return false unless self==other
    return false unless self.morphword == other.morphword
    return true
  end
  
  # Iterates through all feature instances of the input, yielding each
  # to the block. It progresses through the elements in order (in the input),
  # and each feature for a given element is yielded before moving on to
  # the next element.
  def each_feature
    self.each do |element|
      element.each_feature do |feat|
        yield @feature_instance_class.new(element,feat)
      end
    end
  end
  
  # Lists the elements of the input as a string, with dashes between morphemes.
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

  # A string output appropriate for GraphViz.
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

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
  
  # Makes a duplicate of each element when duplicating the input,
  # and makes an appropriately adjusted UI correspondence as well (containing
  # the duplicated elements). The morphword is also duplicated.
  def dup
    copy = Input.new # contents of copy are filled in below
    copy.morphword = @morphword.dup unless @morphword.nil?
    self.each do |old_el|
      new_el = old_el.dup # duplicate the old element
      copy << new_el # add the dup to the copy
      # Get the corresponding underlying element in the original's
      # UI correspondence. If it exists, add a correspondence to the copy
      # between this underlying element and the duplicated input element
      # in the copy.
      under_el = @ui_corr.under_corr(old_el)
      copy.ui_corr << [under_el,new_el] unless under_el.nil?
    end
    return copy
  end

  # Two inputs are the same if they contain equivalent elements.
  # TODO: create separate method #eql_elements? for this. Let #eql?
  # also check equivalence of morphword, maybe ui_corr.
  def ==(other)
    return false unless self.size == other.size
    self.each_index {|idx| return false unless self[idx] == other[idx]}
    return true
  end

  # the same as ==(_other_).
  def eql?(other)
    self==other
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

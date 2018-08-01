# Author: Bruce Tesar

require_relative 'input'
require_relative 'output'
require_relative 'io_correspondence'
require_relative 'candidate'
require_relative 'feature_instance'

# A Word is a candidate (input, output, opt?, constraints),
# combined with an IO correspondence relation and a reference to
# the linguistic system.
class Word
  
  # A word starts out with an empty input and output by default, but
  # input and output can be optionally passed as parameters.
  # The linguistic system is a mandatory parameter, and
  # the correspondence relation is initially empty;
  # correspondences must be added after the word is created.
  def initialize(system, input=Input.new, output=Output.new,
      candidate_class: Candidate, feature_instance_class: FeatureInstance)
    @system = system
    @candidate = candidate_class.new(input, output, nil, @system.constraints)
    @feature_instance_class = feature_instance_class
    @io_corr = IOCorrespondence.new
  end

  # Delegate all method calls not explicitly defined here to the candidate.
  def method_missing(name, *args, &block)
    @candidate.send(name, *args, &block)
  end
  protected :method_missing
  
  # Adds a new IO correspondence pair, with +in_el+ corresponding to +out_el+.
  def add_to_io_corr(in_el, out_el)
    @io_corr.add_corr(in_el, out_el)
  end
  
  # Returns a reference to the IO correspondence of this word.
  def io_corr
    @io_corr
  end

  # Returns a reference to the input's underlying - input
  # correspondence relation.
  def ui_corr
    input.ui_corr
  end

  # Given an output feature instance of this word, return the feature
  # instance for the same feature type of the input correspondent.
  # Returns nil if the output feature does not belong to the output
  # of *this* word, or if the output feature has no input correspondent.
  def in_feat_corr_of_out(out_feat_inst)
    # Make sure the parameter really is a feature instance of an output
    # segment of *this* word.
    return nil unless output.member?(out_feat_inst.element)
    # Get the corresponding input element and feature for the output element.
    in_corr_element = io_corr.in_corr(out_feat_inst.element)
    return nil if in_corr_element.nil?
    in_corr_feat = in_corr_element.get_feature(out_feat_inst.feature.type)
    return FeatureInstance.new(in_corr_element, in_corr_feat)
  end

  # Given an input feature instance of this word, return the feature
  # instance for the same feature type of the output correspondent.
  # Returns nil if the input feature does not belong to the input
  # of *this* word, or if the input feature has no output correspondent.
  def out_feat_corr_of_in(in_feat_inst)
    # Make sure the parameter really is a feature instance of an input
    # segment of *this* word.
    # TODO: this should raise an exception, not return nil
    return nil unless input.member?(in_feat_inst.element)
    # Get the corresponding output element and feature for the input element.
    out_corr_element = io_corr.out_corr(in_feat_inst.element)
    return nil if out_corr_element.nil?
    out_corr_feat = out_corr_element.get_feature(in_feat_inst.feature.type)
    return FeatureInstance.new(out_corr_element, out_corr_feat)
  end

  # Given an input feature instance of this word, return the feature
  # instance for the same feature type of the UF correspondent.
  # Returns nil if the input feature does not belong to the input
  # of *this* word, or if the input feature has no uf correspondent.
  def uf_feat_corr_of_in(in_feat_inst)
    # Make sure the parameter really is a feature instance of an input
    # segment of *this* word.
    return nil unless input.member?(in_feat_inst.element)
    # Get the corresponding uf element and feature for the input element.
    uf_corr_element = ui_corr.under_corr(in_feat_inst.element)
    return nil if uf_corr_element.nil?
    uf_corr_feat = uf_corr_element.get_feature(in_feat_inst.feature.type)
    return FeatureInstance.new(uf_corr_element, uf_corr_feat)
  end

  # Given a uf feature instance of this word, return the feature
  # instance for the same feature type of the input correspondent.
  # Returns nil if the uf feature does not belong to an underlying form
  # of *this* word, or if the uf feature has no input correspondent.
  def in_feat_corr_of_uf(uf_feat_inst)
    # Make sure the parameter really is a feature instance of a uf for
    # a morpheme of *this* word.
    return nil unless ui_corr.in_corr?(uf_feat_inst.element)
    # Get the corresponding input element and feature for the uf element.
    in_corr_element = ui_corr.in_corr(uf_feat_inst.element)
    return nil if in_corr_element.nil?
    in_corr_feat = in_corr_element.get_feature(uf_feat_inst.feature.type)
    return FeatureInstance.new(in_corr_element, in_corr_feat)
  end

  # Returns the output feature instance corresponding to the underlying
  # feature instance _uf_feat_inst_.
  # Returns nil if the uf feature has no input correspondent, or if its
  # input correspondent has no output correspondent.
  def out_feat_corr_of_uf(uf_feat_inst)
    in_feat_inst = in_feat_corr_of_uf(uf_feat_inst)
    # If uf feat has no input correspondent, then it has no output correspondent.
    return nil if in_feat_inst.nil?
    return out_feat_corr_of_in(in_feat_inst)
  end
  
  # Assign each *unset* feature of the input the value of its counterpart
  # feature in the output. Returns a reference to this word.
  def match_input_to_output!
    input.each_feature do |finst|
      if finst.feature.unset? then
        out_feat_instance = out_feat_corr_of_in(finst)
        finst.value = out_feat_instance.value
      end
    end
    eval # re-evaluate constraint violations b/c changed input
    return self
  end

  # Returns a deep copy of the word, with distinct input syllables and features,
  # distinct output elements and features, and appropriately revises UI and
  # IO correspondences.
  def dup
    copy = Word.new(@system)
    copy.label = self.label
    copy.opt=self.opt?
    # Make local references to reduce number of method calls
    c_input = copy.input
    c_output = copy.output
    c_io_corr = copy.io_corr
    # dup the morphological word for the copy's input and output
    unless input.morphword.nil?
      c_morphword = input.morphword.dup
      c_input.morphword = c_morphword
      c_output.morphword = c_morphword
    end
    # Make copies of the old input's elements, creating a map from each
    # old element to its copy.
    input_dup_map = Hash.new
    input.each{|old| input_dup_map[old] = old.dup}
    # Fill the copy input with copies of the input elements, and fill the
    # copy's UI correspondence using the copy input elements.
    input.each do |old_in_el|
      new_in_el = input_dup_map[old_in_el]
      c_input << new_in_el # add the element copy to the input copy
      under_el = ui_corr.under_corr(old_in_el) # UF correspondent
      unless under_el.nil?
        c_input.ui_corr.add_corr(under_el,new_in_el)
      end
    end
    # Fill the copy output with copies of the output elements, and fill the
    # copy's IO correspondence using the copy input and output elements.
    output.each do |old_out_el|
      new_out_el = old_out_el.dup # duplicate the old output element
      c_output << new_out_el # add the element copy to the output copy
      old_in_el = io_corr.in_corr(old_out_el) # old input correspondent
      unless old_in_el.nil?
        new_in_el = input_dup_map[old_in_el]
        c_io_corr.add_corr(new_in_el, new_out_el)
      end
    end
    copy.eval # set the constraint violations
    return copy
  end
  
  # Returns a copy of the word with the same input object, a cloned output
  # containing the same syllable objects, and a new IO correspondence
  # containing the same [input,output] pairs.
  # No copy is made of the label, remark, or constraint violations; those
  # will be as initialized by new(). Thus, constraint violations should be
  # assessed via eval() after competitors are complete. The copied word
  # is set to non-optimal by new().
  # This is used in gen() to create copies for building/extending competitors;
  # all competitors reference the very same input object, and can share
  # output syllable objects.
  def dup_for_gen
    # use clone() method for a shallow copy of output.
    copy = Word.new(@system,input,output.clone)
    input.each do |in_el|
      out_el = io_corr.out_corr(in_el) # output correspondent (if it exists)
      copy.io_corr.add_corr(in_el, out_el) unless out_el.nil?
    end
    return copy
  end

  # Freezes the word, and additionally freezes the IO correspondence
  # relation.
  def freeze
    @candidate.freeze
    @io_corr.freeze
  end

  # Evaluates and stores the number of violations of each constraint by
  # the candidate. This method should be called before externally
  # accessing the constraint violation counts (but after the candidate is
  # complete).
  def eval
    constraint_list.each do |con|
      set_viols(con, con.eval_candidate(self))
    end
    return self
  end
  
  # Returns the morphological word of this word.
  def morphword
    return input.morphword
  end
  
  # Returns the candidate internal to the word.
  # Used in defining #==().
  def candidate
    @candidate
  end
  protected :candidate
  
  # Two words are equivalent if their underlying Candidates are equivalent
  # (input and output are equivalent).
  #--
  # Correspondence relations are assumed for the time being to be
  # order-preserving bijections, so don't bother comparing the IO
  # correspondence relations themselves for the two candidates.
  #++
  def ==(other)
    return @candidate == other.candidate
  end
  
  def eql?(other)
    self==other
  end
  
  def to_s
    input.morphword.to_s + ' ' + @candidate.to_s
  end

end # class Word

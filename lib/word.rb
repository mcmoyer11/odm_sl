# Author: Bruce Tesar
#

require_relative 'input'
require_relative 'output'
require_relative 'io_correspondence'
require_relative 'candidate'

# A Word is a Candidate (input, output, opt?, constraints),
# combined with an IO correspondence relation and a reference to
# the linguistic system.
class Word < Candidate
  
  # A word starts out with an empty input and output by default, but
  # input and output can be optionally passed as parameters.
  # The linguistic system is a mandatory parameter, and
  # the correspondence relation is initially empty;
  # correspondences must be added after the word is created.
  def initialize(system, input=Input.new, output=Output.new)
    @system = system
    super(input, output, nil, @system.constraints)
    @io_corr = IOCorrespondence.new
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
    # Make a copy of the input, constructing updated versions of the UI
    # and IO correspondences using the new copies of the input syllables.
    input.each do |old_in_syl|
      new_in_syl = old_in_syl.dup # duplicate the old input syllable
      c_input << new_in_syl # add the dup to the copy
      # get the corresponding underlying syllable in the original's UI correspondence.
      # If it exists, add a correspondence to the copy between this underlying
      # syllable and the duplicated input syllable in the copy.
      under_syl = input.ui_corr.under_corr(old_in_syl)
      c_input.ui_corr << [under_syl,new_in_syl] unless under_syl.nil?
      # get the corresponding output syllable in the original word's IO corresp.
      out_syl = @io_corr.out_corr(old_in_syl)
      c_io_corr << [new_in_syl,out_syl] unless out_syl.nil?
    end
    # Make a copy of the output, adjusting the O part of IO correspondence.
    output.each do |old_out_syl|
      new_out_syl = old_out_syl.dup # duplicate the old output syllable
      c_output << new_out_syl # add the dup to the copy
      corr_pair = c_io_corr.find{|p| p[1].equal?(old_out_syl)} # find IO corr. pair
      corr_pair[1] = new_out_syl unless corr_pair.nil? # replace old with new output syl.
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
    # Copy the original IO correspondence contents into the new
    # IO correspondence relation.
    copy.io_corr.concat(io_corr)
    return copy
  end

  # Freezes the word, and additionally freezes the IO correspondence
  # relation.
  def freeze
    super
    @io_corr.freeze
  end

  # Changes the UI correspondence of the input so that underlying correspondents
  # are elements of the lexicon in +grammar+. Useful when a grammar
  # has been duplicated (creating a lexicon with distinct underlying elements).
  def sync_with_grammar!(grammar)
    input.sync_with_grammar!(grammar)
    return self
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
  
  # Two words are equivalent if their underlying Candidates are equivalent
  # (input and output are equivalent).
  #--
  # Correspondence relations are assumed for the time being to be
  # order-preserving bijections, so don't bother comparing the IO
  # correspondence relations themselves for the two candidates.
  #++
  def ==(other)
    super
  end
  
  def eql?(other)
    self==other
  end
  
  def to_s
    input.morphword.to_s + ' ' + super
  end

end # class Word

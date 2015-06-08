# Author: Crystal Akers
#
# This file contains a collection of methods for generating and
# manipulating data.

require 'REXML/syncenumerator'
require_relative '../hypothesis'
require_relative '../otlearn'
require_relative '../morph_word'
require_relative '../input'
require_relative '../sf/syllable'
require_relative '../io_correspondence'


module OTLearn

  # Creates and returns an input given an overt form, useful in identity maps.
  # This input has an empty UI correspondence.
  def OTLearn::input_from_overt(overt_form)
    input =  Input.new
    overt_form.each do |syl|
      in_syl = SF::Syllable.new
      in_syl.set_morpheme(syl.morpheme)
      syl.each_feature do |f|
        val = f.value
        in_syl.set_feature(f.type,val)
      end
      input.push(in_syl)
      input.morphword = overt_form.morphword
    end
    return input
  end

  # Performs ranking learning using the given ranking bias.
  def OTLearn::ranking_learning(winner_list, lang_hyp, ranking_bias_flag)
    if ranking_bias_flag == nil then
      OTLearn::ranking_learning_faith_low(winner_list,lang_hyp)
    else
      OTLearn::ranking_learning_mark_low(winner_list,lang_hyp)
    end
  end

  # Creates and returns an input. The input contains all features set in _gram_;
  # any features unset in the lexicon are set in the input to match those in
  # the _overt_ form. This input has an empty UI correspondence.
  def OTLearn::input_from_lexicon_and_overt(overt, gram)
    input = Input.new
    input.morphword = overt.morphword
    mw = input.morphword
    mw.each do |m| # for each morpheme in the morph_word, in order
      uf = gram.get_uf(m)
      # If the morpheme is in the lexicon, add a duplicate of each underlying
      # syllable to input. Otherwise, for each syllable of the morpheme, add a
      # new syllable to the input.
      if uf then
        uf.each { |syl| input.push(syl.dup) }
      else
        m_syls = overt.find_all {|syl| syl.morpheme == m}
        m_syls.each { |syl| input.push(SF::Syllable.new.set_morpheme(m)) }
      end
    end
    # Match any unset features of the input syllables to the values of the corresponding
    # _overt_ syllables.
    gen_syl = REXML::SyncEnumerator.new(input, overt)
    gen_syl.each do |in_syl, o_syl|
      in_syl.each_feature do |f|
        if f.unset? then
          o_feat = o_syl.get_feature(f.type)
          in_syl.set_feature(f.type, o_feat.value)
        end
      end
    end
    return input
  end

  # For the given overt form, test the *unset* features by examining each combination
  # of values such that each unset feature does *not* match its output
  # correspondent. For each combination, the code block is run.
  #
  # If all features are strictly binary, then there is only one input that
  # maximally mismatches the output with respect to the unset features.
  # If one or more features is suprabinary, then the
  # different possible combinations of non-surface-matching values are
  # all tried.
  def OTLearn::mismatches_input_to_overt(gram, overt_form, &block)
    input = Input.new
    input.morphword = overt_form.morphword
    mw = input.morphword
    mw.each do |m| # for each morpheme in the morph_word, in order
      uf = gram.get_uf(m)
      # If the morpheme is in the lexicon, add a duplicate of each underlying
      # syllable to input. Otherwise, for each syllable of the morpheme, add a
      # new syllable to the input.
      if uf then
        uf.each { |syl| input.push(syl.dup) }
      else
        m_syls = overt_form.find_all {|syl| syl.morpheme == m}
        m_syls.each { |syl| input.push(SF::Syllable.new.set_morpheme(m)) }
      end
    end
    # Create an IO correspondence between the input and the overt form.
    io_corr = IOCorrespondence.new
    gen = REXML::SyncEnumerator.new(input, overt_form)
    gen.each do |in_syl,overt_syl|
      io_corr << [in_syl,overt_syl]
      if in_syl.morpheme != overt_syl.morpheme then
        raise "Input syllable morph #{in_syl.morpheme.label} != " +
          "overt syllable morph #{overt_syl.morpheme.label}"
      end
    end
    # Construct a list of the unset features in _input_
    unset_features = []
    input.each do |in_el|
      in_el.each_feature do |f|
        unset_features << FeatureInstance.new(in_el,f) if f.unset?
      end
    end
    # Invoke the block on each combination of mismatched values, by
    # passing the block as a procedure object.
    OTLearn::test_each_overt_mismatch_value(input, io_corr, unset_features, block)
  end

  # Run the provided procedure object _block_proc_ on variations of _input_.
  # The variations are all possible combinations of values for the input
  # features in _unset_features_ such that all of those input features do
  # not match their output correspondent values in a previously given overt form.
  #
  # _block_proc_ is a procedure object version of the code block to be
  # called on each combination of output-mismatched feature values.
  def OTLearn::test_each_overt_mismatch_value(input, io_corr, unset_features, block_proc)
    # Base case: if no unset features remain, call the block on a duplicate
    # of the input, and return.
    if unset_features.empty? then
      block_proc.call(input.dup)
      return
    end
    # Get the first unset feature instance on the list, and make a copy list of
    # the rest of the unset features (that way, the original list is unchanged
    # when referenced by other recursive calls).
    unset_f_inst = unset_features[0]
    rest_unset_features = unset_features.slice(1..-1) # list with first element removed
    # Obtain the value of the unset feature's corresponding instance in the overt form.
    overt_f_inst = OTLearn::overt_feat_corr_of_in(unset_f_inst, io_corr)
    overt_f_val = overt_f_inst.value
    # Obtain the unset feature itself.
    unset_f = unset_f_inst.feature
    # For each value of the unset feature type that does not match the
    # value in the overt correspondent, assign that value to the
    # unset feature *in the input* (i.e., not in the lexicon).
    unset_f.each_value do |val|
      if val!=overt_f_val then
        unset_f.value = val
        OTLearn::test_each_overt_mismatch_value(input,io_corr, rest_unset_features, block_proc)
      end
    end
  end

# Returns the corresponding overt feature instance for the given _in_feat_inst_.
# This method assumes that the corresponding overt feature instance of
# _in_feat_inst_ simply the corresponding output feature instance.
def OTLearn::overt_feat_corr_of_in(in_feat_inst, io_corr)
    # Get the corresponding overt element and feature for the input element.
    overt_corr_element = io_corr.out_corr(in_feat_inst.element)
    return nil if overt_corr_element.nil?
    overt_corr_feat = overt_corr_element.get_feature(in_feat_inst.feature.type)
    return FeatureInstance.new(overt_corr_element, overt_corr_feat)
end


end # module OTLearn


# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/data_manip'
require 'feature_instance'
require 'feature_value_pair'
require 'word_search'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

module OTLearn
  # Using the given list of words, check each unset underlying feature in each
  # morpheme of the word list to see if it can be set.
  def OTLearn.set_uf_values(words, grammar)
    # Duplicate the words (working copies for this method)
    word_list = words.map do |word|
      grammar.parse_output(word.output)
    end
    # Set all unset input features to match their output correspondents
    word_list.each { |word| word.match_input_to_output! }
    # Construct two lists of unset underlying features: those that have
    # conflicting values in the outputs, and those that do not.
    morph_in_words = WordSearch.new.morphemes_to_words(word_list)
    morpheme_list = morph_in_words.keys
    unset_features = WordSearch.new.find_unset_features(morpheme_list, grammar)
    conflict, no_conflict = unset_features.partition do |f|
      conflicting_output_values?(f, morph_in_words[f.morpheme])
    end
    # Test conflicting unset features to see if any can be set
    set_feature_list = []
    conflict_still_unset = []
    until conflict.empty?
      f_uf_instance_c = conflict.shift # take the next conflict feature
      # combine remaining conflict features
      conflict_rest = conflict_still_unset + conflict
      f_was_set =
        OTLearn.test_unset_feature(f_uf_instance_c, word_list,
                                   conflict_rest, grammar)
      if f_was_set
        # add to list of newly set features
        set_feature_list << f_uf_instance_c
      else
        conflict_still_unset << f_uf_instance_c # feature cannot be set
      end
    end
    conflict = conflict_still_unset
    # Test each non-conflicting unset feature to see if it can be set
    no_conflict.each do |f_uf_instance|
      f_was_set =
        OTLearn.test_unset_feature(f_uf_instance, word_list,
                                   conflict, grammar)
      set_feature_list << f_uf_instance if f_was_set
    end
    set_feature_list
  end

  # Tests the given unset feature to see if it can be set relative to the
  # given word list, grammar, and list of conflicting features in the word
  # list. If the feature can be set (it has only one value that is
  # consistent), then the feature is set in the lexicon, the inputs of the
  # words in the word list are changed to match the newly set feature, and
  # a value of true is returned. Otherwise, false is returned.
  def OTLearn.test_unset_feature(f_uf_instance, word_list,
                                 conflict_list, grammar)
    # Find the consistent values for the feature.
    consistent_values =
      OTLearn.consistent_feature_values(f_uf_instance, word_list,
                                        conflict_list, grammar)
    if consistent_values.size > 1 # feature cannot be set
      false
    elsif consistent_values.size == 1
      # Set the uf value, and reset all inputs with that feature.
      f_uf_instance.value = consistent_values.first
      set_input_features(f_uf_instance, consistent_values.first, word_list)
      true
    else # There must be at least one consistent value.
      raise "No feature value for #{f_uf_instance} is consistent."
    end
  end

  # Tests all possible values of the given underlying feature for consistency
  # with respect to the given word list, using the given grammar.
  # Conflict_features is a list of unset features which conflict in their
  # output realizations in the word list; all combinations of values of them
  # must be considered as local lexica when evaluating a given feature value
  # for consistency.
  def OTLearn.consistent_feature_values(f_uf_inst, word_list,
                                        conflict_features, grammar)
    # Find the words of the list containing the target feature's morpheme;
    # these are the only ones that need to have their inputs altered for
    # testing.
    containing_words =
      word_list.find_all { |word| word.morphword.member?(f_uf_inst.morpheme) }
    # Test every value of the target feature; store the consistent values
    consistent_values = []
    f_uf_inst.feature.each_value do |test_val|
      # set the input feature values to match the current loop feature value
      set_input_features(f_uf_inst, test_val, containing_words)
      # see if a combination of conflict features consistent with test_val
      # exists
      consistent_combination_exists =
        eval_over_conflict_features(conflict_features, word_list, grammar)
      consistent_values << test_val if consistent_combination_exists
    end
    # reset input values to match their output values in any event.
    containing_words.each do |word|
      in_f_inst = word.in_feat_corr_of_uf(f_uf_inst)
      out_f_inst = word.out_feat_corr_of_in(in_f_inst)
      in_f_inst.value = out_f_inst.value
    end
    consistent_values
  end

  # Given: contrast_set, grammar, conflict_features
  # Call Mrcd for successive combinations of conflict feature values.
  # If a consistent combination is found, return true, otherwise continue
  # checking combinations. Return false if no combinations are consistent.
  # NOTE: if there are no conflicting features, then the method simply
  # tests the word list as is (with all input features already set) using
  # mrcd, and returns the result (consistency: true/false).
  def OTLearn.eval_over_conflict_features(c_features, contrast_set, grammar)
    # Create a loser selector for Mrcd; the same object works for all passes
    basic_selector = LoserSelector.new(CompareConsistency.new)
    loser_selector = LoserSelectorFromGen.new(grammar.system, basic_selector)
    # Generate a list of feature-value pairs, one for each possible value of
    # each conflict feature.
    feat_values_list = FeatureValuePair.all_values_pairs(c_features)
    # Generate all combinations of values for the conflict features.
    # By default, a single combination of zero conflict features
    conflicting_feature_combinations = [[]]
    # Create the cartesian product of the sets of possible feature values.
    unless feat_values_list.empty?
      conflicting_feature_combinations =
        feat_values_list[0].product(*feat_values_list[1..-1])
    end
    # Test each combination, returning _true_ on the first consistent one.
    conflicting_feature_combinations.each do |feat_comb|
      # Set conflict input features to the feature values in the combination
      feat_comb.each do |feat_pair|
        # Set every occurrence of the feature in the contrast set to
        # the alternative value.
        OTLearn.set_input_features(feat_pair.feature_instance,
                                   feat_pair.alt_value, contrast_set)
      end
      # Test the contrast set, using the conflicting feature combination
      mrcd_result = Mrcd.new(contrast_set, grammar, loser_selector)
      return true if mrcd_result.grammar.consistent?
    end
    false # none of the combinations were consistent.
  end

  # Sets, for each word in the given word list, the input feature
  # corresponding to the given underlying feature to the given feature value.
  def OTLearn.set_input_features(f_uf_inst, value, word_list)
    # unpack the underlying feature instance's containing element and
    # actual feature
    el_uf = f_uf_inst.element
    f_uf = f_uf_inst.feature
    # For each word, reset it's corresp. input element to the given
    # feature value
    word_list.each do |word|
      el_in = word.ui_corr.in_corr(el_uf) # get the corresp. input element
      # skip this word if it does not contain the relevant morpheme
      next if el_in.nil?

      # get the appropriate feature of the input element
      f_in = el_in.get_feature(f_uf.type)
      f_in.value = value # set to the given value
      word.eval # reassess constraint violations in light of modified input
    end
    value # can't think of anything better to return at the moment
  end

  # Checks all of the output correspondents, within the given word list, of
  # the given underlying feature instance. If the output correspondents
  # do not all have the same value for the given feature type, then they
  # conflict, and true is returned; otherwise, false is returned.
  def OTLearn.conflicting_output_values?(uf_feat_inst, word_list)
    out_feature_list = word_list.map { |w| w.out_feat_corr_of_uf(uf_feat_inst) }
    # Remove occurrences of nil (resulting from words in which _uf_feat_inst_
    # has no output correspondent).
    out_feature_list = out_feature_list.reject { |feat| feat.nil? }
    conflict_flag = false
    out_feature_list.inject do |first_f, f|
      conflict_flag = true if first_f.value != f.value
      f
    end
    conflict_flag
  end
end

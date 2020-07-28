# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature_value_pair'
require 'otlearn/consistency_checker'

module OTLearn
  # Tests the given unset feature to see if it can be set relative to the
  # given word list, grammar, and list of conflicting features in the
  # word list. If the feature can be set (it has only one value that is
  # consistent), then the feature is set in the lexicon and
  # a value of true is returned. Otherwise, false is returned.
  def OTLearn.test_unset_feature(f_uf_instance, word_list,
                                 conflict_list, grammar)
    # Find the consistent values for the feature.
    consistent_values = consistent_feature_values(f_uf_instance, word_list,
                                                  conflict_list, grammar)
    if consistent_values.size > 1 # feature cannot be set
      false
    elsif consistent_values.size == 1
      # Set the uf value.
      f_uf_instance.value = consistent_values.first
      true
    else # There must be at least one consistent value.
      raise "No feature value for #{f_uf_instance} is consistent."
    end
  end

  # Tests all possible values of the given underlying feature for
  # consistency with respect to the given word list, using the given
  # grammar. Conflict_features is a list of unset features which conflict
  # in their output realizations in the word list; all combinations of
  # values of them must be considered as local lexica when evaluating
  # a given feature value for consistency.
  # NOTE: the words of _word_list_ may exhibit side effects in their
  # input feature values.
  def OTLearn.consistent_feature_values(f_uf_inst, word_list,
                                        conflict_features, grammar)
    # Test every value of the target feature; store the consistent values
    consistent_values = []
    f_uf_inst.feature.each_value do |test_val|
      # Assign the current loop feature value to the input features
      assign_input_features(f_uf_inst, test_val, word_list)
      # see if a combination of conflict features consistent with test_val
      # exists
      consistent_combination_exists =
        eval_over_conflict_features(conflict_features, word_list, grammar)
      consistent_values << test_val if consistent_combination_exists
    end
    consistent_values
  end

  # Given: contrast_set, grammar, conflict_features
  # Call Mrcd for successive combinations of conflict feature values.
  # If a consistent combination is found, return true, otherwise continue
  # checking combinations. Return false if no combinations are consistent.
  # NOTE: if there are no conflicting features, then the method simply tests
  # the word list as is (with all input features assumed to be already
  # assigned) using mrcd, and returns the result (consistency: true/false).
  def OTLearn.eval_over_conflict_features(c_features, contrast_set,
                                          grammar)
    # Create a consistency checker
    checker = ConsistencyChecker.new
    # Generate a list of feature-value pairs, one for each possible value
    # of each conflict feature.
    feat_values_list = FeatureValuePair.all_values_pairs(c_features)
    # Generate all combinations of values for the conflict features.
    # By default, a single combination of zero conflict features
    conflict_feature_comb = [[]]
    # Create the cartesian product of the sets of possible feature values.
    unless feat_values_list.empty?
      conflict_feature_comb =
        feat_values_list[0].product(*feat_values_list[1..-1])
    end
    # Test each combination, returning _true_ on the first consistent one.
    conflict_feature_comb.each do |feat_comb|
      # Set conflict input features to the feature values in the combination
      feat_comb.each do |feat_pair|
        # Assign the alternative value to every occurrence of the feature
        # in the contrast set.
        assign_input_features(feat_pair.feature_instance,
                              feat_pair.alt_value, contrast_set)
      end
      # Test the contrast set, using the conflicting feature combination
      return true if checker.consistent?(contrast_set, grammar)
    end
    false # none of the combinations were consistent.
  end

  # Assigns the given feature value to the input feature corresponding
  # to the given underlying feature, for each word in the given word list.
  # This method does *not* set any feature values in the lexicon.
  def OTLearn.assign_input_features(f_uf_inst, value, word_list)
    # unpack the underlying feature instance's containing element and
    # actual feature
    el_uf = f_uf_inst.element
    f_uf = f_uf_inst.feature
    # For each word, reset it's corresp. input element to the given
    # feature value
    word_list.each do |word|
      el_in = word.ui_in_corr(el_uf) # get the corresp. input element
      # skip this word if it does not contain the relevant morpheme
      next if el_in.nil?

      # get the appropriate feature of the input element
      f_in = el_in.get_feature(f_uf.type)
      f_in.value = value # assign the given value
      word.eval # reassess constraint violations due to modified input
    end
    value # can't think of anything better to return at the moment
  end
end

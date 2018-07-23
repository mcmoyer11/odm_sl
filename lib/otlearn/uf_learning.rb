# Author: Bruce Tesar
#

require_relative 'data_manip'
require 'loserselector_by_ranking'
require_relative '../feature_instance'
require_relative '../feature_value_pair'

module OTLearn

  # Using the given list of words, check each unset underlying feature in each
  # morpheme of the word list to see if it can be set.
  def OTLearn.set_uf_values(words, grammar)
    # Duplicate the words (working copies for this method)
    word_list = words.map{|word| word.dup}
    # Set all unset input features to match their output correspondents
    word_list.each{|word| OTLearn::match_input_to_uf!(word)}
    word_list.each{|word| OTLearn::match_input_to_output!(word)}
    # Construct two lists of unset underlying features: those that have
    # conflicting values in the outputs, and those that do not.
    morph_in_words = find_morphemes_in_words(word_list)
    morpheme_list = morph_in_words.keys
    unset_features = find_unset_features(morpheme_list,grammar)
    conflict, no_conflict = unset_features.partition do |f|
      conflicting_output_values?(f,morph_in_words[f.morpheme])
    end
    # Test conflicting unset features to see if any can be set
    set_feature_list = []; conflict_still_unset = []
    until conflict.empty? do
      f_uf_instance_c = conflict.shift # take the next conflict feature
      conflict_rest = conflict_still_unset + conflict # combine remaining conflict features
      f_was_set = OTLearn.test_unset_feature(f_uf_instance_c, word_list,
        conflict_rest, grammar)
      if f_was_set then
        set_feature_list << f_uf_instance_c # add to list of newly set features
      else
        conflict_still_unset << f_uf_instance_c # feature cannot be set
      end
    end
    conflict = conflict_still_unset
    # Test each non-conflicting unset feature to see if it can be set
    no_conflict.each do |f_uf_instance|
      f_was_set = OTLearn.test_unset_feature(f_uf_instance, word_list,
        conflict, grammar)
      if f_was_set then
        set_feature_list << f_uf_instance
      end
    end
    return set_feature_list
  end

  # Tests the given unset feature to see if it can be set relative to the
  # given word list, grammar, and list of conflicting features in the word
  # list. If the feature can be set (it has only one value that is
  # consistent), then the feature is set in the lexicon, the inputs of the
  # words in the word list are changed to match the newly set feature, and
  # a value of true is returned. Otherwise, false is returned.
  def OTLearn.test_unset_feature(f_uf_instance, word_list, conflict_list, grammar)
    # Find the consistent values for the feature.
    consistent_values = OTLearn.consistent_feature_values(f_uf_instance,
      word_list, conflict_list, grammar)
    if (consistent_values.size>1) then # feature cannot be set
      return false
    elsif (consistent_values.size==1) then
      # Set the uf value, and reset all inputs with that feature.
      f_uf_instance.value = consistent_values.first
      set_input_features(f_uf_instance, consistent_values.first, word_list)
      return true
    else # There must be at least one consistent value.
      raise "No feature value for #{f_uf_instance.to_s} is consistent."
    end    
  end
  
  # Tests all possible values of the given underlying feature for consistency
  # with respect to the given word list, using the given grammar.
  # Conflict_features is a list of unset features which conflict in their
  # output realizations in the word list; all combinations of values of them
  # must be considered as local lexica when evaluating a given feature value
  # for consistency.
  def OTLearn.consistent_feature_values(f_uf_inst, word_list, conflict_features,
      grammar)
    # Find the words of the list containing the target feature's morpheme;
    # these are the only ones that need to have their inputs altered for testing.
    containing_words =
      word_list.find_all{|word| word.morphword.member?(f_uf_inst.morpheme)}
    # Test every value of the target feature; store the consistent values
    consistent_values = []
    f_uf_inst.feature.each_value do |test_val|
      # set the input feature values to match the current loop feature value
      set_input_features(f_uf_inst, test_val, containing_words)
      # see if a combination of conflict features consistent with test_val exists
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
    return consistent_values
  end
  
  # Given: contrast_set, grammar, conflict_features
  # Call Mrcd for successive combinations of conflict feature values.
  # If a consistent combination is found, return true, otherwise continue
  # checking combinations. Return false if no combinations are consistent.
  # NOTE: if there are no conflicting features, then the method simply
  # tests the word list as is (with all input features already set) using
  # mrcd, and returns the result (consistency: true/false).
  def OTLearn.eval_over_conflict_features(c_features, contrast_set, grammar)
    # Create a loser selector for Mrcd; the same object can be used for all passes
    selector = LoserSelector_by_ranking.new(grammar.system)
    # Generate a list of feature-value pairs, one for each possible value of
    # each conflict feature.
    feat_values_list = FeatureValuePair.all_values_pairs(c_features)
    # Generate all combinations of values for the conflict features.
    # By default, a single combination of zero conflict features
    conflicting_feature_combinations = [[]]
    # Create the cartesian product of the sets of possible feature values.
    unless feat_values_list.empty?
      conflicting_feature_combinations = feat_values_list[0].product(*feat_values_list[1..-1])
    end
    # Test each combination, returning _true_ on the first consistent one.
    conflicting_feature_combinations.each do |feat_comb|
      # Set conflict input features to the feature values in the combination
      feat_comb.each do |feat_pair|
        # Set every occurrence of the feature in the contrast set to the alt value.
        OTLearn::set_input_features(feat_pair.feature_instance, feat_pair.alt_value, contrast_set)
      end
      # Test the contrast set, using the conflicting feature combination
      mrcd_result = Mrcd.new(contrast_set, grammar, selector)
      return true if mrcd_result.grammar.consistent?
    end
    return false # none of the combinations were consistent.    
  end

  # Sets, for each word in the given word list, the input feature
  # corresponding to the given underlying feature to the given feature value.
  def OTLearn.set_input_features(f_uf_inst, value, word_list)
    # unpack the underlying feature instance's containing element and actual feature
    el_uf = f_uf_inst.element; f_uf = f_uf_inst.feature
    # For each word, reset it's corresponding input element to the given feature value
    word_list.each do |word|
      el_in = word.ui_corr.in_corr(el_uf) # get the corresponding input element
      next if el_in.nil? # skip this word if it does not contain the relevant morpheme
      f_in = el_in.get_feature(f_uf.type) # get the appropriate feature of the input element
      f_in.value = value  # set to the given value
      word.eval # reassess constraint violations in light of modified input
    end
    return value # can't think of anything better to return at the moment
  end

  # Checks all of the output correspondents, within the given word list, of
  # the given underlying feature instance. If the output correspondents
  # do not all have the same value for the given feature type, then they
  # conflict, and true is returned; otherwise, false is returned.
  def OTLearn.conflicting_output_values?(uf_feat_inst,word_list)
    out_feature_list = word_list.map{|w| w.out_feat_corr_of_uf(uf_feat_inst)}
    # Remove occurrences of nil (resulting from words in which _uf_feat_inst_
    # has no output correspondent).
    out_feature_list = out_feature_list.reject { |feat| feat.nil? }
    conflict_flag = false
    out_feature_list.inject{|first_f,f| conflict_flag=true if first_f.value!=f.value; f}
    return conflict_flag
  end

  # Checks, for each word in the given list, whether the input correspondent
  # for the given uf feature instance has a different value for the feature.
  # If there are no conflicting instances, nil is returned.
  # Otherwise, a list of the input feature instances that conflict with
  # the uf instance is returned.
  def OTLearn.conflicting_values_on_feat_uf_in(uf_feat_inst, word_list)
    # conflict is vacuously absent if the underlying feature is unset
    return nil if uf_feat_inst.feature.unset?
    in_feat_inst_list = [] # List of input correspondent feature instances
    word_list.each do |word|
      # Skip to the next word unless the uf morpheme is part of this word
      next unless word.morphword.member?(uf_feat_inst.morpheme)
      # Get the corresponding input element for the uf element
      in_feat_inst = word.in_feat_corr_of_uf(uf_feat_inst)
      next if in_feat_inst.nil? # Skip to next word if there is no correspondent.
      # If input feature value doesn't match the underlying feature value,
      # add the input feature instance to the list.
      unless (in_feat_inst.value == uf_feat_inst.value)
        in_feat_inst_list << in_feat_inst
      end
    end
    return nil if in_feat_inst_list.empty?
    return in_feat_inst_list
  end

  # Returns a list of the input feature instances in _word_list_
  # that conflict with their uf correspondents.
  def OTLearn.conflicting_values_uf_in(word_list)
    conflicting_feature_list = []
    word_list.each do |word|
      word.input.each do |in_el|
        in_el.each_feature do |in_feat|
          in_feat_inst = FeatureInstance.new(in_el,in_feat)
          # compare with uf feature
          uf_feat_inst = word.uf_feat_corr_of_in(in_feat_inst)
          next if uf_feat_inst.feature.unset?
          if in_feat_inst.value != uf_feat_inst.value
            conflicting_feature_list << in_feat_inst
          end
        end
      end
    end
    return conflicting_feature_list
  end

  def OTLearn.find_unset_features_in_words(word_list, grammar)
    # Build hash of morphemes and the words in the list that contain them
    morph_in_words = find_morphemes_in_words(word_list)
    # Extract a list of the morphemes in the words (the keys of the hash)
    morpheme_list = morph_in_words.keys
    # Return a list of the unset features for the morphemes
    return find_unset_features(morpheme_list,grammar)
  end

  # Returns a list of all the uf features in each of the morphemes in
  # the given list that are unset in the given grammar.
  def OTLearn.find_unset_features(morpheme_list,grammar)
    unset_features = []
    morpheme_list.each do |morph|
      # find all of the unset features for that morpheme
      uf = grammar.get_uf(morph)
      uf.each do |el| # for each correspondence level element of the uf
        el.each_feature do |f|
          unset_features << FeatureInstance.new(el,f) if f.unset?
        end
      end
    end
    return unset_features
  end
  
  # Given a list of words, returns a hash mapping each morpheme that
  # occurs in the word list to an array of the words (in the list) in which
  # they occur.
  def OTLearn.find_morphemes_in_words(word_list)
    morph_in_words = Hash.new
    word_list.each do |w|
      w.morphword.each do |morph|
        if morph_in_words.has_key?(morph) then
          morph_in_words[morph] = morph_in_words[morph] << w
        else
          morph_in_words[morph] = [w]
        end
      end
    end
    return morph_in_words
  end
  
  # Looks for new ranking information from nonfaithful mappings of the given
  # feature within the given word list, relative to the given grammar.
  # Any new ranking information is added to the grammar.
  # Returns true if any new ranking information was obtained; false otherwise.
  def OTLearn.new_rank_info_from_feature(grammar, word_list, uf_feat_inst,
      learning_module: OTLearn, loser_selector: nil)
    # Assign the default value for loser_selector
    if loser_selector.nil? then
      loser_selector = LoserSelectorExhaustive.new(grammar.system)
    end
    # find words containing the same morpheme as the set feature
    containing_words = word_list.find_all do |w|
      w.morphword.include?(uf_feat_inst.morpheme)
    end
    # find words with output value of set feature that differs from the uf set value.
    uo_conflict_words = containing_words.inject([]) do |cwords, word|
      out_feat_inst = word.out_feat_corr_of_uf(uf_feat_inst)
      unless out_feat_inst.nil?
        cwords << word if uf_feat_inst.value != out_feat_inst.value
      end
      cwords
    end
    # Duplicate and output-match the conflict words
    dup_conflict_words = uo_conflict_words.map do |word|
      dup = grammar.system.parse_output(word.output, grammar.lexicon)
      learning_module.match_input_to_output!(dup)
      dup
    end
    # Run each such word through MRCD, searching for new ranking info
    return learning_module.
      ranking_learning(dup_conflict_words, grammar, loser_selector)
  end
  
end # module OTLearn

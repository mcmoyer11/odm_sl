# Author: Bruce Tesar
#
# This file contains a collection of methods for generating and
# manipulating data.
 
module OTLearn
  
  # For the given word, set each *unset* feature of the input to the value
  # of that feature type in the corresponding element of the output.
  # Returns a reference to the word itself.
  def OTLearn::match_input_to_output!(word)
    input = word.input
    input.each do |element|  # For each element of the input
      element.each_feature do |f|  # For each feature of the input element
        if f.unset? then
          # Set the input feature value to match the value of
          # the corresponding feature in the output.
          out_feat_inst = word.out_feat_corr_of_in(FeatureInstance.new(element,f))
          f.value = out_feat_inst.value
        end
      end
    end
    word.eval # re-evaluate constraint violations b/c changed input
  end
  
  # For the given word, test the *unset* features by examining each combination
  # of values such that each unset feature does *not* match its output
  # correspondent. For each combination, the code block is run.
  #
  # If all features are strictly binary, then there is only one input that
  # maximally mismatches the output with respect to the unset features.
  # If one or more features is suprabinary, then the
  # different possible combinations of non-surface-matching values are
  # all tried.
  #-- TODO: test on supra-binary features. ++
  def OTLearn::mismatches_input_to_output(word_param, &block)
    word = word_param.dup
    OTLearn::match_input_to_uf!(word)
    # Construct a list of the unset features in the word
    unset_features = []
    input = word.input
    input.each do |in_el|
      in_el.each_feature do |f|
        unset_features << FeatureInstance.new(in_el,f) if f.unset?
      end
    end
    # Invoke the block on each combination of mismatched values, by
    # passing the block as a procedure object.
    test_each_mismatch_value(word, unset_features, block)
  end
  
  # Run the provided procedure object _block_proc_ on variations of _word_.
  # The variations are all possible combinations of values for the input
  # features in _unset_features_ such that all of those input features do
  # not match their output correspondent values in _word_.
  # 
  # _block_proc_ is a procedure object version of the code block to be
  # called on each combination of output-mismatched feature values.
  def OTLearn::test_each_mismatch_value(word, unset_features, block_proc)
    # Base case: if no unset features remain, call the block on a duplicate
    # of the word, and return.
    if unset_features.empty? then
      block_proc.call(word.dup)
      return
    end
    # Get the first unset feature instance on the list, and make a copy list of
    # the rest of the unset features (that way, the original list is unchanged
    # when referenced by other recursive calls).
    unset_f_inst = unset_features[0]
    rest_unset_features = unset_features.slice(1..-1) # list with first element removed
    # Obtain the value of the unset feature's corresponding instance in the output.
    out_f_inst = word.out_feat_corr_of_in(unset_f_inst)
    out_f_val = out_f_inst.value
    # Obtain the unset feature itself.
    unset_f = unset_f_inst.feature
    # For each value of the unset feature type that does not match the
    # value in the output correspondent, assign that value to the
    # unset feature *in the input* (i.e., not in the lexicon).
    unset_f.each_value do |val|
      if val!=out_f_val then
        unset_f.value = val
        test_each_mismatch_value(word, rest_unset_features, block_proc)
      end
    end
  end

  # For the given word, set each feature of the input to the value
  # of the corresponding feature in the lexicon.
  # Returns a reference to the word itself.
  def OTLearn::match_input_to_uf!(word)
    input = word.input
    input.each do |in_el|
      # Set each input element feature to the value of its underlying correspondent
      in_el.each_feature do |f|
        uf_feat_inst = word.uf_feat_corr_of_in(FeatureInstance.new(in_el, f))
        f.value = uf_feat_inst.value
      end
    end
    word.eval # re-evaluate constraint violations b/c changed input
    return word
  end

  # Takes a competition list and a hierarchy, and returns a list of
  # structural descriptions that are optimal with respect to the hierarchy.
  # The returned structural description objects are the same objects as
  # the matching ones in the competition list. Each optimal description has
  # its optimal flag set to true.
  def OTLearn::generate_language_from_competitions(comp_list, hier)
    comp_mh = comp_list.map{|comp| MostHarmonic.new(comp,hier)}
    # each competition returns a list of winners; collapse to one-level list.
    lang = comp_mh.inject([]){|winners, mh_list| winners.concat(mh_list) }
    lang.each{|winner| winner.assert_opt}
    return lang
  end

  # Takes a language in the form of a comparative tableau of WL pairs (with
  # each represented form of the language appearing as a winner in at least
  # one pair), along with the grammar class object for the linguistic system,
  # and returns a list of the winner outputs and an associated fresh hypothesis.
  def OTLearn::convert_ct_to_learning_data(lang_ct, grammar_class)
    # Extract the outputs of the grammatical candidates of the language.
    outputs = lang_ct.winners.map{|winner| winner.output}
    # Construct a new hypothesis with an empty lexicon and no WL pairs.
    hypothesis = Hypothesis.new(grammar_class.new)
    return outputs, hypothesis
  end

  # Takes a competition list, a constraint hierarchy, and a grammar class
  # object for a linguistic system, and returns a list of the winners with
  # respect to the hierarchy, and a corresponding empty hypothesis. The winners
  # have inputs with no set features (matching the lexicon).
  def OTLearn::generate_learning_data_from_competitions(comp_list, hier, grammar_class)
    # Obtain the optimal candidates for the given hierarchy.
    lang = generate_language_from_competitions(comp_list, hier)
    # Obtain the output forms of the language
    outputs = lang.map{|winner| winner.output}
    # Obtain a fresh, empty hypothesis.
    hyp = Hypothesis.new(grammar_class.new)
    # Convert the outputs to full words, using the new hypothesis,
    # populating the lexicon with the morphemes of the outputs in the process.
    # parse_output() adds the morphemes of the output forms to the lexicon,
    # and constructs a UI correspondence for the input of each word, connecting
    # to the underlying forms of the lexicon of the new hypothesis.
    winner_list = outputs.map{|out| hyp.system.parse_output(out, hyp.lexicon)}
    return winner_list, hyp
  end
  
end # module OTLearn

# Author: Bruce Tesar
#

require_relative 'contrast_pair'
require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative '../loserselector_by_ranking'
require_relative 'uf_learning'
require_relative 'mrcd'
require_relative 'data_manip'
require_relative '../feature_value_pair'

module OTLearn

  # A LanguageLearning object instantiates a particular instance of
  # language learning. An instance is created with a set of outputs
  # (the data to be learned from), and a starting hypothesis (which
  # will likely be altered during the course of learning).
  #
  # The learning proceeds in the following stages, in order:
  # * Phonotactic learning.
  # * Single form learning (one word at a time until no more can be learned).
  # * Repeat until the language is learned or no more progress is made.
  #   * Try a contrast pair; if none are successful, try minimum uf setting.
  #   * If either of these is successful, and the language is not yet learned,
  #     run another round of single form learning.
  # After each stage in which hypothesis change occurs, the state of
  # the learner is stored and evaluated in a GrammarTest object. These
  # objects are stored in a list, obtainable via #results_list().
  #
  # Learning is initiated upon construction of the object.
  class LanguageLearning

    # Executes learning on _outputs_ with respect to _hypothesis_, and
    # stores the results in the returned LanguageLearning object.
    def initialize(outputs, hypothesis)
      @outputs = outputs
      @hyp = hypothesis
      @results_list = []
      # Convert the outputs to full words, using the new hypothesis,
      # populating the lexicon with the morphemes of the outputs in the process.
      # parse_output() adds the morphemes of the output forms to the lexicon,
      # and constructs a UI correspondence for the input of each word, connecting
      # to the underlying forms of the lexicon of the new hypothesis.
      @winner_list = @outputs.map{|out| @hyp.system.parse_output(out, @hyp.grammar.lexicon)}
      @learning_successful = execute_learning
    end

    # Returns the outputs that were the data for learning.
    def data_outputs() return @outputs end

    # Returns the winners (full candidates) that were used as interpretations of the outputs.
    def data_winners() return @winner_list end

    # Returns the final grammar hypothesis that was the result of learning.
    def hypothesis() return @hyp end

    # Returns a boolean indicating if learning was successful.
    def learning_successful?() return @learning_successful end

    # Returns the list of grammar_test objects generated at various stages
    # of learning.
    def results_list()
      @results_list
    end

    # The main, top-level method for executing learning. This method is
    # protected, and called by the constructor #initialize, so learning
    # is automatically executed whenever a LanguageLearning object is
    # created.
    # Returns true if learning was successful, false otherwise.
    def execute_learning
      # Phonotactic learning
      OTLearn::ranking_learning_faith_low(@winner_list, @hyp)
      @results_list << OTLearn::GrammarTest.new(@winner_list, @hyp, "Phonotactic Learning")
      return true if @results_list.last.all_correct?
      # Single form UF learning
      run_single_forms_until_no_change(@winner_list, @hyp)
      @results_list << OTLearn::GrammarTest.new(@winner_list, @hyp, "Single Form Learning")
      return true if @results_list.last.all_correct?
      # Pursue further learning until the language is learned, or no
      # further improvement is made.
      learning_change = true
      while learning_change
        learning_change = false
        # First, try to learn from a contrast pair
        contrast_pair = run_contrast_pair(@winner_list, @hyp, @results_list.last)
        unless contrast_pair.nil?
          @results_list << OTLearn::GrammarTest.new(@winner_list, @hyp, "Contrast Pair Learning")
          learning_change = true
        else
          # No suitable contrast pair, so pursue a step of minimal UF learning
          set_feature = run_minimal_uf_for_failed_winner(@winner_list, @hyp, @results_list.last)
          unless set_feature.nil?
            @results_list << OTLearn::GrammarTest.new(@winner_list, @hyp, "Minimal UF Learning")
            learning_change = true
          end
        end
        # If no change resulted from a contrast pair or from minimal uf learning,
        # no further learning is currently possible, so break out of the loop.
        # Otherwise, check to see if the change completed learning.
        break unless learning_change
        return true if @results_list.last.all_correct?
        # Follow up with another round of single form learning
        change_on_single_forms = run_single_forms_until_no_change(@winner_list, @hyp)
        if change_on_single_forms then
          @results_list << OTLearn::GrammarTest.new(@winner_list, @hyp, "Single Form Learning")
          return true if @results_list.last.all_correct?
        end
      end
      # Return boolean indicating if learning was successful.
      # This should be false, because a "true" would have triggered an earlier
      # return from this method.
      fail if @results_list.last.all_correct?
      return @results_list.last.all_correct?
    end

    # This method processes all of the words in _winners_, one at a time in
    # order, with respect to the hypothesis _hyp_. Each winner is processed
    # as follows:
    # * Error test the winner: see if it is the sole optimum for the
    #   mismatched input (all unset features assigned opposite their
    #   surface values) using the Faith-Low hierarchy.
    # * Check if the winner is optimal when unset input features are matched
    #   to the output, and if not, find more ranking info.
    # * Attempt to set any unset underlying features of the winner.
    # * For each newly set feature, check for new ranking information.
    # It passes repeatedly through the list of winners until a pass is made
    # with no changes to the grammar.
    # A boolean is returned indicating if the grammar was changed at all
    # during the execution of this method.
    def run_single_forms_until_no_change(winners, hyp)
      grammar_ever_changed = false
      grammar_changed_on_pass = true
      while grammar_changed_on_pass do
        grammar_changed_on_pass = false
        winners.each do |winner|
          # Error test the winner by checking to see if it is the sole
          # optimum for the mismatched input using the Faith-Low hierarchy.
          error_test = OTLearn::GrammarTest.new([winner], hyp)
          # Unless no error is detected, try learning with the winner.
          unless error_test.all_correct? then
            # Check the winner to see if it is the sole optimum for
            # the matched input; if not, more ranking info is gained.
            new_ranking_info = OTLearn::ranking_learning_faith_low([winner], hyp)
            grammar_changed_on_pass = true if new_ranking_info
            # Check the mismatched input for consistency.
            # Unless the mismatched winner is consistent, attempt to set
            # each unset feature of the winner.
            consistency_result = mismatch_consistency_check(hyp, [winner])
            unless consistency_result.hypothesis.consistent?
              set_feature_list = OTLearn.set_uf_values([winner], hyp)
              grammar_changed_on_pass = true unless set_feature_list.empty?
              # For each newly set feature, check words unfaithfully mapping that
              # feature for new ranking information.
              set_feature_list.each do |set_f|
                OTLearn::new_rank_info_from_feature(hyp, winners, set_f)
              end
            end
          end
        end
        grammar_ever_changed = true if grammar_changed_on_pass
      end
      return grammar_ever_changed
    end

    # Select a contrast pair, and process it, attempting to set underlying
    # features. If any features are set, check for any newly available
    # ranking information.
    # 
    # This method returns the first contrast pair that was able to set
    # at least one underlying feature. If none of the constructed
    # contrast pairs is able to set any features, nil is returned.
    def run_contrast_pair(winner_list, hyp, prior_result)
      # Create an external iterator which calls generate_contrast_pair()
      # to generate contrast pairs.
      cp_gen = Enumerator.new do |result|
        OTLearn::generate_contrast_pair(result, winner_list, hyp, prior_result)
      end
      # Process contrast pairs until one is found that sets an underlying
      # feature, or until all contrast pairs have been processed.
      loop do
        contrast_pair = cp_gen.next
        # Process the contrast pair, and return a list of any features
        # that were newly set during the processing.
        set_feature_list = OTLearn::set_uf_values(contrast_pair, hyp)
        # For each newly set feature, see if any new ranking information
        # is now available.
        set_feature_list.each do |set_f|
          OTLearn::new_rank_info_from_feature(hyp, winner_list, set_f)
        end
        # If an underlying feature was set, return the contrast pair.
        # Otherwise, keep processing contrast pairs.
        return contrast_pair unless set_feature_list.empty?
      end
      # No contrast pairs were able to set any features; return nil.
      # NOTE: loop silently rescues StopIteration, so if cp_gen runs out
      #       of contrast pairs, loop simply terminates, and execution continues
      #       below it.
      return nil
    end

    # Given the result of error-testing, find a previously unset feature
    # for one of the failed winners such that setting it to match its
    # surface correspondent in the failed winner results in the winner
    # succeeding (consistent with all of the winners that passed
    # error-testing). This method is expected to be invoked only when
    # single-word and contrast-pair inconsistency detection has failed
    # to completely learn the language, suggesting that a paradigmatic
    # subset relation is present. The goal is to find the smallest set
    # of feature values that will allow learning to continue (fewer set
    # features corresponds to greater restrictiveness).
    # Each failed winner is checked in turn until one is found that can
    # succeed on the basis of one newly set feature, returning that instance
    # without checking to see if there are other possibilities.
    #
    # Returns the feature instance of the newly set feature, or nil if
    # no feature was set.
    #
    # At present, #select_most_restrictive_uf checks each unset feature of
    # a failed winner in isolation, and returns a feature value allowing
    # that winner to succeed if there is exactly one.
    # In principle, if there is no single feature leading to success for
    # a previously failed winner, this method should try combinations
    # of two unset features (and larger, if necessary) to find the minimum
    # set of additional feature value commitments resulting in the success
    # of a failed winner. Future work will be needed to determine if
    # the learner should evaluate each failed winner, and then select
    # the failed winner requiring the minimal number of set features.
    def run_minimal_uf_for_failed_winner(winner_list, hyp, prior_result)
      fw_list = prior_result.failed_winners
      set_feature = nil
      fw_list.each do |failed_winner|
        # Get the FeatureValuePair of the feature and its succeeding value.
        fv_pair = select_most_restrictive_uf(failed_winner, hyp, prior_result.success_winners)
        unless fv_pair.nil?
          fv_pair.set_to_alt_value  # Set the feature permanently in the lexicon.
          set_feature = fv_pair.feature_instance
          # Check for any new ranking information based on the newly set feature.
          OTLearn::new_rank_info_from_feature(hyp, winner_list, set_feature)
          break # Stop looking once the first successful feature is found.
        end
      end
      return set_feature
    end

    # Finds the unset underlying form feature of _failed_winner_ that,
    # when assigned a value matching its output correspondent,
    # makes _failed_winner_ consistent with the success winners. Consistency
    # is evaluated with respect to the parameter _main_hypothesis_ with its
    # lexicon augmented to include the tested underlying feature value, and with
    # the other unset features given input values opposite of their output values).
    #
    # Returns nil if none of the features succeeds.
    # Raises an exception if more than one underlying feature succeeds.
    # Returns the successful underlying feature (and value) if exactly one of them succeeds.
    # The return value is a _FeatureValuePair_: the underlying feature instance and
    # its successful value (the one matching its output correspondent in the
    # previously failed winner).
    def select_most_restrictive_uf(failed_winner_orig, main_hypothesis, success_winners)
      failed_winner = failed_winner_orig.dup.sync_with_hypothesis!(main_hypothesis)
      # Find the unset underlying feature instances
      unset_uf_features = OTLearn::find_unset_features_in_words([failed_winner],main_hypothesis)
      # Set, in turn, each unset feature to match its output correspondent.
      # For each case, test the success winners and the current failed winner
      # for collective consistency with the hypothesis.
      # TODO: generalize from one set feature to minimum number
      consistent_feature_val_list = []
      unset_uf_features.each do |ufeat|
        # set the tested underlying feature to the output value
        out_feat_inst = failed_winner.out_feat_corr_of_uf(ufeat)
        ufeat.value = out_feat_inst.value
        # Add the failed winner to (a dup of) the list of success winners.
        word_list = success_winners.dup
        word_list << failed_winner
        # Check the list of words for consistency, using the main hypothesis,
        # with each word's unset features mismatching their output correspondents.
        mrcd_result = mismatch_consistency_check(main_hypothesis, word_list)
        # If result is consistent, add the UF value to the list.
        if mrcd_result.hypothesis.consistent? then
          ufeat_val_pair = FeatureValuePair.new(ufeat, ufeat.value)
          consistent_feature_val_list << ufeat_val_pair
        end
        # Unset the tested feature in any event.
        ufeat.value = nil
      end
      # Return the consistent tested feature if there is exactly one.
      return nil if consistent_feature_val_list.empty?
      if consistent_feature_val_list.size > 1 then
        raise "More than one single matching feature passes error testing."
        # TODO: handle this more gracefully.
      end
      return consistent_feature_val_list[0] # the single element of the list.
    end

    # Given a list of words and a hypothesis, check the word list for
    # consistency with the hypothesis using MRCD. Any features unset
    # in the lexicon of the hypothesis are set in the input of a word
    # to the value opposite its output correspondent in the word.
    # The mismatching is done separately for each word (the same unset feature
    # for a morpheme might be assigned different values in the inputs of
    # different words containing that morpheme, depending on what the outputs
    # of those words are).
    # Returns the Mrcd object containing the results.
    # To find out if the word list is consistent with the hypothesis, call
    # result.hypothesis.consistent? (where result is the Mrcd object returned
    # by #mismatch_consistency_check).
    def mismatch_consistency_check(hypothesis, word_list)
      # Dup hypothesis and words, so originals aren't modified.
      hyp = hypothesis.dup
      w_list = word_list.map { |winner| winner.dup.sync_with_hypothesis!(hyp) }
      # Set each word's input so that features unset in the hypothesis lexicon
      # mismatch their output correspondents. A given output could appear
      # more than once in the mismatch list ONLY if there are suprabinary
      # features (a suprabinary feature can mismatch in more than one way).
      mismatch_list = []
      w_list.map do |word|
        OTLearn::mismatches_input_to_output(word) { |mismatched_word| mismatch_list << mismatched_word }
      end
      # Run MRCD to see if the mismatched candidates are consistent.
      selector = LoserSelector_by_ranking.new(@hyp.system)
      return Mrcd.new(mismatch_list, hyp, selector)
    end

    protected :execute_learning, :run_single_forms_until_no_change,
      :run_contrast_pair, :run_minimal_uf_for_failed_winner,
      :select_most_restrictive_uf

  end # class LanguageLearning
  
end # module OTLearn

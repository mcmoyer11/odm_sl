# Author: Bruce Tesar
#

require_relative 'data_manip'
require_relative '../feature_value_pair'
require_relative 'learning_exceptions'

module OTLearn
  
  # FewestSetFeatures searches for a single unset feature that, when set to
  # its surface realization for a word, allows that word to pass
  # word evaluation.
  # This class would typically be invoked when neither single form learning nor
  # contrast pairs are able to make further progress, yet learning is
  # not yet complete.
  class FewestSetFeatures
    
    # Initializes a new object, but does *not* automatically execute
    # the fewest set features algorithm; #run() must be called to do that.
    # * +prior_result+ is the most recent result of grammar testing, and
    #   provides a list of the winners failing word evaluation.
    # * +grammar+ is the current grammar of the learner.
    # * +language_learner+ provides access to the method #mismatch_consistency_check().
    # * +word_list+ is a list of all the winners (words) currently stored by
    #   the learner. It is used when searching for non-phonotactic ranking
    #   information when a feature has been set.
    def initialize(word_list, grammar, prior_result, language_learner)
      @word_list = word_list
      @grammar = grammar
      @prior_result = prior_result
      @language_learner = language_learner
      @newly_set_features = []
    end

    # Returns an array of the feature that were set by fewest set features.
    # If no feature was set, returns nil. Will necessarily return nil if
    # FewestSetFeatures#run has not yet been called on this object.
    def newly_set_features
      return @newly_set_features
    end
    
    # Returns true if FewestSetFeatures set at least one feature.
    # Will necessarily return false if FewestSetFeatures#run has not yet
    # been called on this object.
    def change?
      return (not newly_set_features.empty?)
    end

    # Executes the fewest set features algorithm. If a minimal set if features
    # is identified, they are set in the grammar. Returns true if at least
    # one feature was set, false otherwise.
    def run
      run_minimal_uf_for_failed_winner(@word_list, @grammar, @prior_result)
      return change?
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
    # Returns true if the grammar set a feature, false otherwise.
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
    def run_minimal_uf_for_failed_winner(winner_list, grammar, prior_result)
      fw_list = prior_result.failed_winners
      fw_list.each do |failed_winner|
        # Get the FeatureValuePair of the feature and its succeeding value.
        fv_pair = select_most_restrictive_uf(failed_winner, grammar, prior_result.success_winners)
        unless fv_pair.nil?
          fv_pair.set_to_alt_value  # Set the feature permanently in the lexicon.
          set_feature = fv_pair.feature_instance
          newly_set_features << set_feature
          # Check for any new ranking information based on the newly set feature.
          OTLearn::new_rank_info_from_feature(grammar, winner_list, set_feature)
          break # Stop looking once the first successful feature is found.
        end
      end
      return change?
    end
    
    # Finds the unset underlying form feature of +failed_winner+ that,
    # when assigned a value matching its output correspondent,
    # makes +failed_winner+ consistent with the success winners. Consistency
    # is evaluated with respect to the parameter +main_grammar+ with its
    # lexicon augmented to include the tested underlying feature value, and with
    # the other unset features given input values opposite of their output values).
    #
    # Returns nil if none of the features succeeds.
    # Raises an exception if more than one underlying feature succeeds.
    # Returns the successful underlying feature (and value) if exactly one of them succeeds.
    # The return value is a +FeatureValuePair+: the underlying feature instance and
    # its successful value (the one matching its output correspondent in the
    # previously failed winner).
    def select_most_restrictive_uf(failed_winner_orig, main_grammar, success_winners)
      failed_winner = failed_winner_orig.dup.sync_with_grammar!(main_grammar)
      # Find the unset underlying feature instances
      unset_uf_features = OTLearn::find_unset_features_in_words([failed_winner],main_grammar)
      # Set, in turn, each unset feature to match its output correspondent.
      # For each case, test the success winners and the current failed winner
      # for collective consistency with the grammar.
      # TODO: generalize from one set feature to minimum number
      consistent_feature_val_list = []
      unset_uf_features.each do |ufeat|
        # set the tested underlying feature to the output value
        out_feat_inst = failed_winner.out_feat_corr_of_uf(ufeat)
        ufeat.value = out_feat_inst.value
        # Add the failed winner to (a dup of) the list of success winners.
        word_list = success_winners.dup
        word_list << failed_winner
        # Check the list of words for consistency, using the main grammar,
        # with each word's unset features mismatching their output correspondents.
        mrcd_result = @language_learner.mismatch_consistency_check(main_grammar, word_list)
        # If result is consistent, add the UF value to the list.
        if mrcd_result.grammar.consistent? then
          ufeat_val_pair = FeatureValuePair.new(ufeat, ufeat.value)
          consistent_feature_val_list << ufeat_val_pair
        end
        # Unset the tested feature in any event.
        ufeat.value = nil
      end
      # Return the consistent tested feature if there is exactly one.
        return nil if consistent_feature_val_list.empty?
        if consistent_feature_val_list.size > 1 then
          # If a feature-value=pair causes this error, we initialize a LearnEx object
          # which will hold the langauge_learning object and the feature_val_list 
          # to be fed later up the chain so we can look at the stage of learning
          # that goes awry.
          raise LearnEx.new(@language_learner, consistent_feature_val_list), "More than one single matching feature passes error testing."
        end
        return consistent_feature_val_list[0] # the single element of the list.
    end
    
    protected :select_most_restrictive_uf, :run_minimal_uf_for_failed_winner

  end # class FewestSetFeatures
end # module OTLearn

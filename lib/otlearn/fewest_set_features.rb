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
  # not yet complete, suggesting that a paradigmatic subset relation is present.
  #
  # The name "fewest set features" refers to the idea that more features
  # need to be set to make a word successful, but setting fewer features
  # correlates with greater restrictiveness, so the learner should set the
  # minimal number of features necessary to get the word to succeed. At
  # present, the learner implements "minimal number of features" as
  # "only one feature".
  # In principle, this algorithm can be generalized to search for a minimal
  # number of features to set (as the name implies), rather than only a
  # single one. Implementation of that is waiting for the discovery of
  # a case where it is necessary.
  #
  # Future research will be needed to determine if
  # the learner should evaluate each failed winner, and then select
  # the failed winner requiring the minimal number of set features.
  class FewestSetFeatures
    
    # Initializes a new object, but does _not_ automatically execute
    # the fewest set features algorithm; #run() must be called to do that.
    # * +prior_result+ is the most recent result of grammar testing, and
    #   provides a list of the winners failing word evaluation.
    # * +grammar+ is the current grammar of the learner.
    # * +language_learner+ provides access to the method
    #   #mismatch_consistency_check().
    # * +word_list+ is a list of all the winners (words) currently stored by
    #   the learner. It is used when searching for non-phonotactic ranking
    #   information when a feature has been set.
    def initialize(word_list, grammar, prior_result, language_learner)
      @word_list = word_list
      @grammar = grammar
      @prior_result = prior_result
      @language_learner = language_learner
      @failed_winner = nil
      @newly_set_features = []
      # dependency injection defaults
      @uf_learning_module = OTLearn
    end

    # Returns an array of the features that were set by fewest set features.
    # If no feature was set, returns nil. Will necessarily return nil if
    # FewestSetFeatures#run has not yet been called on this object.
    #
    # NOTE: at present, OTLearn::FewestSetFeatures will set at most one
    # feature, but may be extended to return a minimal set of features
    # in the future, so this method returns a list.
    def newly_set_features
      return @newly_set_features
    end
    
    # Returns the failed winner that was used with fewest set features.
    # Will necessarily return nil if
    # FewestSetFeatures#run has not yet been called on this object.
    def failed_winner
      return @failed_winner
    end
    
    # Returns true if FewestSetFeatures set at least one feature.
    # Will necessarily return false if FewestSetFeatures#run has not yet
    # been called on this object.
    def change?
      return (not newly_set_features.empty?)
    end
    
    # Assigns a new module to be used as the source of the underlying
    # form learning methods. Used for testing (dependency injection).
    # To be effective, this must be called before #run() is called.
    # The uf_learning module is the source of the methods:
    # * .new_rank_info_from_feature(grammar, word_list, feature)
    # * .find_unset_features_in_words(failed_winner_list, grammar)
    def uf_learning_module=(mod)
      @uf_learning_module = mod
    end

    # Executes the fewest set features algorithm.
    # 
    # The learner considers only the first failed winner on the list
    # returned by prior_result. If a unique single feature is identified
    # among the unset features of the failed winner that rescues that winner,
    # then that feature is set in the grammar. The learner pursues
    # non-phonotactic ranking information for the newly set feature.
    # 
    # Returns true if at least one feature was set, false otherwise.
    # 
    # If more than one individual unset feature is found that will succeed
    # for the selected failed winner, then a LearnEx exception is raised,
    # containing references to the language_learner object and the list
    # of (more than one) successful features.
    def run
      # Select a failed winner.
      # At present, the learner simply takes the first one on the list
      # of failed winners provided by @prior_result.
      @failed_winner = @prior_result.failed_winners[0]
      # find a feature that can rescue the failed winner.
      find_and_set_a_succeeding_feature(@failed_winner)
      # Check for any new ranking information based on the newly set features.
      # NOTE: currently, only one feature can be newly set, but it is stored
      # in the list newly_set_features.
      newly_set_features.each do |feat|
        @uf_learning_module.new_rank_info_from_feature(@grammar, @word_list, feat)
      end
      return change?
    end

    # Given +failed_winner+, find a previously unset feature of +failed_winner+
    # such that setting it to match its surface correspondent results in
    # the winner succeeding (consistent with all of the winners that passed
    # error-testing).
    #
    # Returns true if the grammar set a feature, false otherwise.
    def find_and_set_a_succeeding_feature(failed_winner)
      # Look for a feature that can make +failed_winner+ succeed.
      # If one is found, store the successful FeatureValuePair.
      fv_pair = select_most_restrictive_uf(failed_winner)
      # if a feature was found, set in the lexicon, and
      # add it to the list of newly set features.
      unless fv_pair.nil?
        fv_pair.set_to_alt_value  # Set the feature permanently in the lexicon.
        newly_set_features << fv_pair.feature_instance
      end
      return change?
    end
    
    # Finds the unset underlying form feature of +failed_winner+ that,
    # when assigned a value matching its output correspondent,
    # makes +failed_winner+ consistent with the success winners. Consistency
    # is evaluated with respect to the grammar with its
    # lexicon augmented to include the tested underlying feature value, and with
    # the other unset features given input values opposite of their output values).
    # 
    # Returns the successful underlying feature (and value) if exactly
    # one of them succeeds. The return value is a +FeatureValuePair+:
    # the underlying feature instance and its successful value (the one
    # matching its output correspondent in the previously failed winner).
    #
    # Returns nil if none of the features succeeds.
    # 
    # Raises a LearnEx exception if more than one feature succeeds.
    def select_most_restrictive_uf(failed_winner_orig)
      failed_winner = failed_winner_orig.dup.sync_with_grammar!(@grammar)
      # Find the unset underlying feature instances
      unset_uf_features = @uf_learning_module.find_unset_features_in_words([failed_winner],@grammar)
      # Assign, in turn, each unset feature to match its output correspondent.
      # Then test the modified failed winner along with
      # the success winners for collective consistency with the grammar.
      consistent_feature_val_list = []
      unset_uf_features.each do |ufeat|
        ufeat_val_pair = test_unset_feature(failed_winner, ufeat)
        unless ufeat_val_pair.nil? then
          consistent_feature_val_list << ufeat_val_pair
        end
      end
      # Return: nil if no successful values, val_pair if one successful value.
      # Raise a LearnEx exception if more than one successful value is found.
      case consistent_feature_val_list.size
      when 0
        return nil # nil if no successful value was found
      when 1
        return consistent_feature_val_list[0] # the single element of the list.
      else
        raise LearnEx.new(@language_learner, consistent_feature_val_list),
          "More than one single matching feature passes error testing."        
      end
    end

    # Tests the unset feature +ufeat+ of +failed_winner+ by assigning,
    # in the lexicon, the unset feature to the value matching its surface
    # realization in +failed_winner+, and then running a mismatch consistency
    # check on +failed_winner+ jointly with all of the previously successful
    # winners. If the check comes back consistent, then the feature is
    # successful. In any event, the tested feature is unset at the end
    # of the test.
    # 
    # Returns a feature-value pair (the feature, along with the value matching
    # the surface realization in +failed_winner+) if the feature is successful.
    # Returns nil if the feature is not successful.
    def test_unset_feature(failed_winner, ufeat)
      # set the tested underlying feature to the output value
      out_feat_inst = failed_winner.out_feat_corr_of_uf(ufeat)
      ufeat.value = out_feat_inst.value
      # Add the failed winner to (a dup of) the list of success winners.
      word_list = @prior_result.success_winners.dup
      word_list << failed_winner
      # Check the list of words for consistency, using the main grammar,
      # with each word's unset features mismatching their output correspondents.
      mrcd_result = @language_learner.mismatch_consistency_check(@grammar, word_list)
      # If result is consistent, add the UF value to the list.
      val_pair = nil
      if mrcd_result.grammar.consistent? then
        val_pair = FeatureValuePair.new(ufeat, ufeat.value)
      end
      # Unset the tested feature in any event.
      ufeat.value = nil
      # return the val_pair if it worked, or nil if it didn't
      return val_pair
    end

    protected :select_most_restrictive_uf, :find_and_set_a_succeeding_feature,
      :test_unset_feature

  end # class FewestSetFeatures
end # module OTLearn

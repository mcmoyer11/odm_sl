# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative '../loserselector_by_ranking'
require_relative 'uf_learning'
require_relative 'mrcd'
require_relative 'data_manip'
require_relative '../feature_value_pair'

module OTLearn
  
  class InductionLearning

      def initialize(word_list, grammar, prior_result, language_learner)
       @word_list = word_list
       @grammar = grammar
       @prior_result = prior_result
       @language_learner = language_learner
       @change = false
      end

   # Returns true if anything changed about the grammar
      def run_induction_learning
        # Collect all the failed winners in a list
        failed_winners = @word_list.select do |word|
          OTLearn::GrammarTest.new([word], @grammar).all_correct?
        end
        # Check those errors for consistency, and collect them
        consistent_list = failed_winners.select do |word|
          @language_learner.mismatch_consistency_check(@grammar, [word]).grammar.consistent?
        end
        # If there are consistent errors, run MMR on one
        #if consistent_list.empty?
        if true
           # Should call FSF
           set_feature = run_minimal_uf_for_failed_winner(@word_list, @grammar, @prior_result)
           @change = true unless set_feature.nil?
        else
          # Should call MMR on the first member of the list
          consistent_list.each do |c|
            new_ranking_info = run_max_mismatch_ranking(c, @grammar)
            @change = true if new_ranking_info
            break if new_ranking_info
          end
        end
        return true
      end

      # Returns True if any new ranking information was added, false otherwise
      def run_max_mismatch_ranking(word, grammar)
        max_disparity_list = []
        OTLearn::mismatches_input_to_output(word) {|cand| max_disparity_list << cand }
        winner = max_disparity_list.first 
        #STDERR.puts winner
        OTLearn::ranking_learning_faith_low([winner], grammar)
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
    def run_minimal_uf_for_failed_winner(winner_list, grammar, prior_result)
      fw_list = prior_result.failed_winners
      set_feature = nil
      fw_list.each do |failed_winner|
        # Get the FeatureValuePair of the feature and its succeeding value.
        fv_pair = select_most_restrictive_uf(failed_winner, grammar, prior_result.success_winners)
        unless fv_pair.nil?
          fv_pair.set_to_alt_value  # Set the feature permanently in the lexicon.
          set_feature = fv_pair.feature_instance
          # Check for any new ranking information based on the newly set feature.
          OTLearn::new_rank_info_from_feature(grammar, winner_list, set_feature)
          break # Stop looking once the first successful feature is found.
        end
      end
      return set_feature
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
      
    def change?
      return @change
    end

    protected :select_most_restrictive_uf, :run_minimal_uf_for_failed_winner,
      :run_max_mismatch_ranking
   end #class Induction_learning
end #module OTLearn
# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative '../../lib/otlearn/max_mismatch_ranking'

RSpec.describe OTLearn::MaxMismatchRanking do
  context "if #run is not called" do
    before(:each) do
      @failed_winner = double("failed_winner")
      grammar = double("grammar")
      @max_mismatch_ranking =
        OTLearn::MaxMismatchRanking.new(@failed_winner, grammar)
      # dependency injection here
      @ranking_learning_module = double("ranking_learning_module")
      @max_mismatch_ranking.ranking_learning_module = @ranking_learning_module
    end
    
    it "returns an empty list of winner-loser pairs" do
      expect(@max_mismatch_ranking.newly_added_wl_pairs).to be_empty
    end
    
    it "indicates no change has occurred" do
      expect(@max_mismatch_ranking.change?).to be false
    end     
  end #context "if #run is not called"
  
  
#  context "given a failed winner" do
#    before(:each) do
#      # mock the parameters
#      @word_list = double('word_list').as_null_object
#      @grammar = double('grammar')
#      @prior_result = double('prior_result')
#      @language_learner = double('language_learner')
#      # set up prior_result to return a list with one failed winner
#      @failed_winner = double('failed_winner')
#      allow(@prior_result).to receive(:failed_winners).and_return([@failed_winner])
#      allow(@prior_result).to receive(:success_winners).and_return([])
#      # mrcd_result is returned when a feature is tested for consistency
#      @mrcd_result = double('mrcd_result')
#      @mrcd_grammar = double('mrcd_grammar')
#      allow(@mrcd_result).to receive(:grammar).and_return(@mrcd_grammar)
#      
#      # a test double of OTLearn for dependency injection
#      @ranking_learning_module = double('ranking_learning_module')
#      # arguments for new_rank_info_from_wlpair specified in expectations
#      allow(@ranking_learning_module).to receive(:ranking_learning_faith_low)
#      
#      # the value of the target features' output correspondents
#      @out_feat_instance1 = double('out_feat_instance1')
#      @out_feat_value1 = double('out_feat_value1')
#      allow(@out_feat_instance1).to receive(:value).and_return(@out_feat_value1)
#      @out_feat_instance2 = double('out_feat_instance2')
#      @out_feat_value2 = double('out_feat_value2')
#      allow(@out_feat_instance2).to receive(:value).and_return(@out_feat_value2)
#      # The possible unset features and their behavior
#      @unset_feat1 = double('unset_feature_1')
#      @unset_feat2 = double('unset_feature_2')
#      allow(@unset_feat1).to receive(:value=).with(@out_feat_value1)
#      allow(@unset_feat1).to receive(:value).and_return(@out_feat_value1)
#      allow(@unset_feat1).to receive(:value=).with(nil)
#      allow(@unset_feat2).to receive(:value=).with(@out_feat_value2)
#      allow(@unset_feat2).to receive(:value).and_return(@out_feat_value2)
#      allow(@unset_feat2).to receive(:value=).with(nil)
#      # mock the dup of failed_winner used to test a feature
#      @failed_winner_dup = double('failed_winner_dup')
#      allow(@failed_winner).to receive(:dup).and_return(@failed_winner_dup)
#      allow(@failed_winner_dup).to receive(:sync_with_grammar!)
#      allow(@language_learner).to \
#        receive(:mismatch_consistency_check).with(@grammar,[@failed_winner_dup]).and_return(@mrcd_result)
#      allow(@failed_winner_dup).to \
#        receive(:out_feat_corr_of_uf).with(@unset_feat1).and_return(@out_feat_instance1)
#      allow(@failed_winner_dup).to \
#        receive(:out_feat_corr_of_uf).with(@unset_feat2).and_return(@out_feat_instance2)
#      # a test double of FeatureValuePair for dependency injection
#      @feature_value_pair_class = double('FeatureValuePair class')
#      @fv_pair1 = double('feature-value pair1')
#      @fv_pair2 = double('feature-value pair2')
#      allow(@feature_value_pair_class).to \
#        receive(:new).with(@unset_feat1,@out_feat_value1).and_return(@fv_pair1)
#      allow(@feature_value_pair_class).to \
#        receive(:new).with(@unset_feat2,@out_feat_value2).and_return(@fv_pair2)
#      allow(@fv_pair1).to receive(:feature_instance).and_return(@unset_feat1)
#      allow(@fv_pair2).to receive(:feature_instance).and_return(@unset_feat2)
#      allow(@fv_pair1).to receive(:set_to_alt_value)
#      allow(@fv_pair2).to receive(:set_to_alt_value)
#      # actually construct the test object, and inject the test dependencies
#      
#      
#      @max_mismatch_ranking = OTLearn::MaxMismatchRanking.new(@word_list,
#        @grammar, @prior_result, @language_learner)
#      @max_mismatch_ranking.ranking_learning_module = @ranking_learning_module
#      @max_mismatch_rankings.win_lose_pair_class = @win_lose_pair_class
#    end  
#    
#    context "with one consistent unset feature" do
#      before(:each) do
#        allow(@ranking_learning_module).to 
#        
#          receive(:ranking_learning_faith_low).with([@failed_winner_dup],@grammar).and_return([@unset_feat1])
#        allow(@mrcd_grammar).to receive(:consistent?).and_return(true)
#        @fewest_set_features.run
#      end
#      
#      it "sets a feature" do
#        expect(@fewest_set_features.change?).to be true
#      end
#      it "determines the failed winner" do
#        expect(@fewest_set_features.failed_winner).to equal @failed_winner
#      end
#      it "only sets one feature" do
#        expect(@fewest_set_features.newly_set_features.size).to eq 1
#      end
#      it "sets the single unset feature" do
#        expect(@fewest_set_features.newly_set_features[0]).to eq @unset_feat1
#      end
#      it "checks for new ranking information for the unset feature" do
#        expect(@uf_learning_module).to \
#          have_received(:new_rank_info_from_feature).with(@grammar,@word_list,@unset_feat1)
#      end
#    end
#  end
  
  
end #describe MaxMismatchRanking



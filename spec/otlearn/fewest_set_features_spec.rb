# Author: Bruce Tesar

require 'otlearn/fewest_set_features'

RSpec.describe OTLearn::FewestSetFeatures do
  # mock the parameters
  let(:word_list){double('word_list').as_null_object}
  let(:grammar){double('grammar')}
  let(:prior_result){double('prior_result')}
  let(:language_learner){double('language_learner')}
  let(:learning_module){double('learning_module')}
  let(:loser_selector){double('loser_selector')}
  let(:feature_value_pair_class){double('FeatureValuePair class')}
  before(:example) do
    allow(grammar).to receive(:parse_output)
  end

  context "given a failed winner" do
    # mocks of internal objects
    let(:failed_winner){double('failed_winner')}
    let(:failed_winner_dup){double('failed_winner_dup')}
    let(:mrcd_result){double('mrcd_result')}
    let(:mrcd_grammar){double('mrcd_grammar')}
    let(:out_feat_instance1){double('out_feat_instance1')}
    let(:out_feat_value1){double('out_feat_value1')}
    let(:out_feat_instance2){double('out_feat_instance2')}
    let(:out_feat_value2){double('out_feat_value2')}
    let(:unset_feat1){double('unset_feature_1')}
    let(:unset_feat2){double('unset_feature_2')}
    let(:fw_output){double('fw_output')}
    let(:fv_pair1){double('feature-value pair1')}
    let(:fv_pair2){double('feature-value pair2')}
    before(:example) do
      # set up prior_result to return a list with one failed winner
      allow(prior_result).to receive(:failed_winners).and_return([failed_winner])
      allow(prior_result).to receive(:success_winners).and_return([])
      # mrcd_result is returned when a feature is tested for consistency
      allow(mrcd_result).to receive(:grammar).and_return(mrcd_grammar)
      # arguments for new_rank_info_from_feature specified in expectations
      allow(learning_module).to receive(:new_rank_info_from_feature)
      # the value of the target features' output correspondents
      allow(out_feat_instance1).to receive(:value).and_return(out_feat_value1)
      allow(out_feat_instance2).to receive(:value).and_return(out_feat_value2)
      # The possible unset features and their behavior
      allow(unset_feat1).to receive(:value=).with(out_feat_value1)
      allow(unset_feat1).to receive(:value).and_return(out_feat_value1)
      allow(unset_feat1).to receive(:value=).with(nil)
      allow(unset_feat2).to receive(:value=).with(out_feat_value2)
      allow(unset_feat2).to receive(:value).and_return(out_feat_value2)
      allow(unset_feat2).to receive(:value=).with(nil)
      # mock the parse of failed_winner's output used to test a feature
      allow(failed_winner).to receive(:output).and_return(fw_output)
      allow(grammar).to receive(:parse_output).with(fw_output).and_return(failed_winner_dup)
      allow(learning_module).to \
        receive(:mismatch_consistency_check).with(grammar,[failed_winner_dup]).and_return(mrcd_result)
      allow(failed_winner_dup).to \
        receive(:out_feat_corr_of_uf).with(unset_feat1).and_return(out_feat_instance1)
      allow(failed_winner_dup).to \
        receive(:out_feat_corr_of_uf).with(unset_feat2).and_return(out_feat_instance2)
      # a test double of FeatureValuePair for dependency injection
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat1,out_feat_value1).and_return(fv_pair1)
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat2,out_feat_value2).and_return(fv_pair2)
      allow(fv_pair1).to receive(:feature_instance).and_return(unset_feat1)
      allow(fv_pair2).to receive(:feature_instance).and_return(unset_feat2)
      allow(fv_pair1).to receive(:set_to_alt_value)
      allow(fv_pair2).to receive(:set_to_alt_value)
    end
    
    context "with one consistent unset feature" do
      before(:example) do
        allow(learning_module).to \
          receive(:find_unset_features_in_words).with([failed_winner_dup],grammar).and_return([unset_feat1])
        allow(mrcd_grammar).to receive(:consistent?).and_return(true)
        # actually construct the test object, and inject the test dependencies
        @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list,
          grammar, prior_result, language_learner,
          learning_module: learning_module,
          feature_value_pair_class: feature_value_pair_class,
          loser_selector: loser_selector)
      end
      it "sets a feature" do
        expect(@fewest_set_features.changed?).to be true
      end
      it "determines the failed winner" do
        expect(@fewest_set_features.failed_winner).to equal failed_winner
      end
      it "only sets one feature" do
        expect(@fewest_set_features.newly_set_features.size).to eq 1
      end
      it "sets the single unset feature" do
        expect(@fewest_set_features.newly_set_features[0]).to eq unset_feat1
      end
      it "checks for new ranking information for the unset feature" do
        expect(learning_module).to \
          have_received(:new_rank_info_from_feature).with(grammar,word_list,unset_feat1,loser_selector: loser_selector)
      end
    end
    
    context "with one inconsistent unset feature" do
      before(:example) do
        allow(learning_module).to \
          receive(:find_unset_features_in_words).with([failed_winner_dup],grammar).and_return([unset_feat1])
        allow(mrcd_grammar).to receive(:consistent?).and_return(false)
        # actually construct the test object, and inject the test dependencies
        @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list,
          grammar, prior_result, language_learner,
          learning_module: learning_module,
          feature_value_pair_class: feature_value_pair_class,
          loser_selector: loser_selector)
      end
      it "does not set a feature" do
        expect(@fewest_set_features.changed?).to be false
      end
      it "does not return a failed winner" do
        expect(@fewest_set_features.failed_winner).to be_nil
      end
      it "sets zero features" do
        expect(@fewest_set_features.newly_set_features.size).to eq 0
      end
      it "does not check for new ranking information" do
        expect(learning_module).not_to \
          have_received(:new_rank_info_from_feature)
      end
    end

    context "with one consistent and one inconsistent unset feature" do
      before(:example) do
        allow(learning_module).to \
          receive(:find_unset_features_in_words).with([failed_winner_dup],grammar).and_return([unset_feat1, unset_feat2])
        allow(mrcd_grammar).to receive(:consistent?).and_return(true, false)
        # actually construct the test object, and inject the test dependencies
        @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list,
          grammar, prior_result, language_learner,
          learning_module: learning_module,
          feature_value_pair_class: feature_value_pair_class,
          loser_selector: loser_selector)
      end
      it "sets a feature" do
        expect(@fewest_set_features.changed?).to be true
      end
      it "determines the failed winner" do
        expect(@fewest_set_features.failed_winner).to equal failed_winner
      end
      it "only sets one feature" do
        expect(@fewest_set_features.newly_set_features.size).to eq 1
      end
      it "sets the consistent unset feature" do
        expect(@fewest_set_features.newly_set_features[0]).to eq unset_feat1
      end
      it "checks for new ranking information for the consistent unset feature" do
        expect(learning_module).to \
          have_received(:new_rank_info_from_feature).with(grammar,word_list,unset_feat1, loser_selector: loser_selector)
      end
    end

    context "with one inconsistent and one consistent unset feature" do
      before(:example) do
        allow(learning_module).to \
          receive(:find_unset_features_in_words).with([failed_winner_dup],grammar).and_return([unset_feat1, unset_feat2])
        allow(mrcd_grammar).to receive(:consistent?).and_return(false, true)
        # actually construct the test object, and inject the test dependencies
        @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list,
          grammar, prior_result, language_learner,
          learning_module: learning_module,
          feature_value_pair_class: feature_value_pair_class,
          loser_selector: loser_selector)
      end
      it "sets a feature" do
        expect(@fewest_set_features.changed?).to be true
      end
      it "determines the failed winner" do
        expect(@fewest_set_features.failed_winner).to equal failed_winner
      end
      it "only sets one feature" do
        expect(@fewest_set_features.newly_set_features.size).to eq 1
      end
      it "sets the consistent unset feature" do
        expect(@fewest_set_features.newly_set_features[0]).to eq unset_feat2
      end
      it "checks for new ranking information for the consistent unset feature" do
        expect(learning_module).to \
          have_received(:new_rank_info_from_feature).with(grammar,word_list,unset_feat2,loser_selector: loser_selector)
      end
    end
    
    context "with two consistent features" do
      before(:example) do
        allow(learning_module).to \
          receive(:find_unset_features_in_words).with([failed_winner_dup],grammar).and_return([unset_feat1, unset_feat2])
        allow(mrcd_grammar).to receive(:consistent?).and_return(true, true)
      end
      it "raises a LearnEx exception" do
        expect do
          # actually construct the test object, and inject the test dependencies
          @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list,
            grammar, prior_result, language_learner,
            learning_module: learning_module,
            feature_value_pair_class: feature_value_pair_class,
            loser_selector: loser_selector)
        end.to raise_error(LearnEx)
      end
    end
  end # "given a failed winner"
  
  context "given an unsuccessful failed winner and a successful one" do
    let(:failed_winner_1){double('failed_winner_1')}
    let(:failed_winner_1_dup){double('failed_winner_1_dup')}
    let(:failed_winner_2){double('failed_winner_2')}
    let(:failed_winner_2_dup){double('failed_winner_2_dup')}
    let(:fw_output_1){double('fw_output_1')}
    let(:fw_output_2){double('fw_output_2')}
    let(:mrcd_result_1){double('mrcd_result_1')}
    let(:mrcd_result_2){double('mrcd_result_2')}
    let(:mrcd_grammar_1){double('mrcd_grammar_1')}
    let(:mrcd_grammar_2){double('mrcd_grammar_2')}
    let(:out_feat_instance1){double('out_feat_instance1')}
    let(:out_feat_value1){double('out_feat_value1')}
    let(:out_feat_instance2){double('out_feat_instance2')}
    let(:out_feat_value2){double('out_feat_value2')}
    let(:unset_feat1){double('unset_feature_1')}
    let(:unset_feat2){double('unset_feature_2')}
    let(:fv_pair1){double('feature-value pair1')}
    let(:fv_pair2){double('feature-value pair2')}
    before(:example) do
      # set up prior_result
      allow(prior_result).to receive(:failed_winners).
        and_return([failed_winner_1, failed_winner_2])
      allow(prior_result).to receive(:success_winners).and_return([])
      
      # Failed winner 1
      allow(failed_winner_1).to receive(:output).and_return(fw_output_1)
      allow(grammar).to receive(:parse_output).with(fw_output_1).and_return(failed_winner_1_dup)
      allow(learning_module).to receive(:mismatch_consistency_check).
        with(grammar,[failed_winner_1_dup]).and_return(mrcd_result_1)
      allow(mrcd_result_1).to receive(:grammar).and_return(mrcd_grammar_1)
      allow(learning_module).to receive(:find_unset_features_in_words).
        with([failed_winner_1_dup],grammar).and_return([unset_feat1])
      allow(failed_winner_1_dup).to \
        receive(:out_feat_corr_of_uf).with(unset_feat1).and_return(out_feat_instance1)
      allow(out_feat_instance1).to receive(:value).and_return(out_feat_value1)

      # Failed winner 2
      allow(failed_winner_2).to receive(:output).and_return(fw_output_2)
      allow(grammar).to receive(:parse_output).with(fw_output_2).and_return(failed_winner_2_dup)
      allow(learning_module).to receive(:mismatch_consistency_check).
        with(grammar,[failed_winner_2_dup]).and_return(mrcd_result_2)
      allow(mrcd_result_2).to receive(:grammar).and_return(mrcd_grammar_2)
      allow(learning_module).to receive(:find_unset_features_in_words).
        with([failed_winner_2_dup],grammar).and_return([unset_feat2])
      allow(failed_winner_2_dup).to \
        receive(:out_feat_corr_of_uf).with(unset_feat2).and_return(out_feat_instance2)
      allow(out_feat_instance2).to receive(:value).and_return(out_feat_value2)

      # arguments for new_rank_info_from_feature specified in expectations
      allow(learning_module).to receive(:new_rank_info_from_feature)
      # The possible unset features and their behavior
      allow(unset_feat1).to receive(:value=).with(out_feat_value1)
      allow(unset_feat1).to receive(:value).and_return(out_feat_value1)
      allow(unset_feat1).to receive(:value=).with(nil)
      allow(unset_feat2).to receive(:value=).with(out_feat_value2)
      allow(unset_feat2).to receive(:value).and_return(out_feat_value2)
      allow(unset_feat2).to receive(:value=).with(nil)
      # a test double of FeatureValuePair for dependency injection
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat1,out_feat_value1).and_return(fv_pair1)
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat2,out_feat_value2).and_return(fv_pair2)
      allow(fv_pair1).to receive(:feature_instance).and_return(unset_feat1)
      allow(fv_pair2).to receive(:feature_instance).and_return(unset_feat2)
      allow(fv_pair1).to receive(:set_to_alt_value)
      allow(fv_pair2).to receive(:set_to_alt_value)
    end
    context "with the first failed winner inconsistent" do
      before(:example) do
        allow(mrcd_grammar_1).to receive(:consistent?).and_return(false)
        allow(mrcd_grammar_2).to receive(:consistent?).and_return(true)
        # actually construct the test object, and inject the test dependencies
        @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list,
          grammar, prior_result, language_learner,
          learning_module: learning_module,
          feature_value_pair_class: feature_value_pair_class,
          loser_selector: loser_selector)        
      end
      it "sets a feature" do
        expect(@fewest_set_features.changed?).to be true
      end
      it "determines the failed winner" do
        expect(@fewest_set_features.failed_winner).to equal failed_winner_2
      end
      it "only sets one feature" do
        expect(@fewest_set_features.newly_set_features.size).to eq 1
      end
      it "sets the consistent unset feature" do
        expect(@fewest_set_features.newly_set_features[0]).to eq unset_feat2
      end
      it "checks for new ranking information for the unset feature" do
        expect(learning_module).to \
          have_received(:new_rank_info_from_feature).with(grammar,word_list,unset_feat2, loser_selector: loser_selector)
      end
    end
    context "with the first failed winner consistent" do
      before(:example) do
        allow(mrcd_grammar_1).to receive(:consistent?).and_return(true)
        allow(mrcd_grammar_2).to receive(:consistent?).and_return(true)
        # actually construct the test object, and inject the test dependencies
        @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list,
          grammar, prior_result, language_learner,
          learning_module: learning_module,
          feature_value_pair_class: feature_value_pair_class,
          loser_selector: loser_selector)
      end
      it "sets a feature" do
        expect(@fewest_set_features.changed?).to be true
      end
      it "determines the failed winner" do
        expect(@fewest_set_features.failed_winner).to equal failed_winner_1
      end
      it "only sets one feature" do
        expect(@fewest_set_features.newly_set_features.size).to eq 1
      end
      it "sets the consistent unset feature" do
        expect(@fewest_set_features.newly_set_features[0]).to eq unset_feat1
      end
      it "checks for new ranking information for the unset feature" do
        expect(learning_module).to \
          have_received(:new_rank_info_from_feature).with(grammar,word_list,unset_feat1, loser_selector: loser_selector)
      end
    end
  end
  
end # RSpec.describe OTLearn::FewestSetFeatures

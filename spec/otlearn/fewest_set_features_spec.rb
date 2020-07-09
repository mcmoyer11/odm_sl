# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/fewest_set_features'
require 'otlearn/learning_exceptions'

RSpec.describe OTLearn::FewestSetFeatures do
  # mock the parameters
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:prior_result) { double('prior_result') }
  let(:para_erc_learner) { double('para_erc_learner') }
  let(:consistency_checker) { double('consistency_checker') }
  let(:feature_value_pair_class) { double('FeatureValuePair class') }
  let(:word_search) { double('word_search') }
  before(:example) do
    allow(grammar).to receive(:parse_output)
    allow(para_erc_learner).to receive(:run)
    allow(word_search).to receive(:find_unset_features_in_words)
  end

  context 'given a failed winner' do
    # mocks of internal objects
    let(:failed_winner) { double('failed_winner') }
    let(:failed_winner_dup) { double('failed_winner_dup') }
    let(:out_feat_instance1) { double('out_feat_instance1') }
    let(:out_feat_value1) { double('out_feat_value1') }
    let(:out_feat_instance2) { double('out_feat_instance2') }
    let(:out_feat_value2) { double('out_feat_value2') }
    let(:unset_feat1) { double('unset_feature_1') }
    let(:unset_feat2) { double('unset_feature_2') }
    let(:fw_output) { double('fw_output') }
    let(:fv_pair1) { double('feature-value pair1') }
    let(:fv_pair2) { double('feature-value pair2') }
    before(:example) do
      # set up prior_result to return a list with one failed winner
      allow(prior_result).to receive(:failed_winners).and_return([failed_winner])
      allow(prior_result).to receive(:success_winners).and_return([])
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
      allow(grammar).to receive(:parse_output).with(fw_output)\
                                              .and_return(failed_winner_dup)
      allow(consistency_checker).to receive(:mismatch_consistent?)
      allow(failed_winner_dup).to \
        receive(:out_feat_corr_of_uf)\
        .with(unset_feat1).and_return(out_feat_instance1)
      allow(failed_winner_dup).to \
        receive(:out_feat_corr_of_uf)\
        .with(unset_feat2).and_return(out_feat_instance2)
      # a test double of FeatureValuePair for dependency injection
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat1, out_feat_value1).and_return(fv_pair1)
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat2, out_feat_value2).and_return(fv_pair2)
      allow(fv_pair1).to receive(:feature_instance).and_return(unset_feat1)
      allow(fv_pair2).to receive(:feature_instance).and_return(unset_feat2)
      allow(fv_pair1).to receive(:set_to_alt_value)
      allow(fv_pair2).to receive(:set_to_alt_value)
    end

    context 'with one consistent unset feature' do
      before(:example) do
        allow(word_search).to \
          receive(:find_unset_features_in_words)\
          .with([failed_winner_dup], grammar).and_return([unset_feat1])
        allow(failed_winner_dup).to receive(:output).and_return(fw_output)
        allow(consistency_checker).to\
          receive(:mismatch_consistent?).with([fw_output], grammar)\
                                        .and_return(true)
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          OTLearn::FewestSetFeatures.new(consistency_checker: consistency_checker,
          feature_value_pair_class: feature_value_pair_class,
          word_search: word_search)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end
      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end
      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner
      end
      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end
      it 'sets the single unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat1
      end
      it 'checks for new ranking information for the unset feature' do
        expect(para_erc_learner).to\
          have_received(:run).with(unset_feat1, grammar, output_list)
      end
    end

    context 'with one inconsistent unset feature' do
      before(:example) do
        allow(word_search).to \
          receive(:find_unset_features_in_words)\
          .with([failed_winner_dup], grammar).and_return([unset_feat1])
        allow(failed_winner_dup).to receive(:output).and_return(fw_output)
        allow(consistency_checker).to\
          receive(:mismatch_consistent?).with([fw_output], grammar)\
                                        .and_return(false)
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          OTLearn::FewestSetFeatures.new(consistency_checker: consistency_checker,
          feature_value_pair_class: feature_value_pair_class,
                                         word_search: word_search)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end
      it 'does not set a feature' do
        expect(@substep.changed?).to be false
      end
      it 'does not return a failed winner' do
        expect(@substep.failed_winner).to be_nil
      end
      it 'sets zero features' do
        expect(@substep.newly_set_features.size).to eq 0
      end
      it 'does not check for new ranking information' do
        expect(para_erc_learner).not_to have_received(:run)
      end
    end

    context 'with one consistent and one inconsistent unset feature' do
      before(:example) do
        allow(word_search).to \
          receive(:find_unset_features_in_words)\
          .with([failed_winner_dup], grammar).and_return([unset_feat1, unset_feat2])
        allow(failed_winner_dup).to receive(:output).and_return(fw_output)
        allow(consistency_checker).to\
          receive(:mismatch_consistent?).and_return(true, false)
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          OTLearn::FewestSetFeatures.new(consistency_checker: consistency_checker,
          feature_value_pair_class: feature_value_pair_class,
                                         word_search: word_search)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end
      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end
      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner
      end
      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end
      it 'sets the consistent unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat1
      end
      it 'checks for new ranking information for the consistent unset feature' do
        expect(para_erc_learner).to \
          have_received(:run).with(unset_feat1, grammar, output_list)
      end
    end

    context 'with one inconsistent and one consistent unset feature' do
      before(:example) do
        allow(word_search).to \
          receive(:find_unset_features_in_words)\
          .with([failed_winner_dup], grammar).and_return([unset_feat1, unset_feat2])
        allow(failed_winner_dup).to receive(:output).and_return(fw_output)
        allow(consistency_checker).to\
          receive(:mismatch_consistent?).and_return(false, true)
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
            OTLearn::FewestSetFeatures.new(consistency_checker: consistency_checker,
          feature_value_pair_class: feature_value_pair_class,
                                           word_search: word_search)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end
      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end
      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner
      end
      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end
      it 'sets the consistent unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat2
      end
      it 'checks for new ranking information for the consistent unset feature' do
        expect(para_erc_learner).to\
          have_received(:run).with(unset_feat2, grammar, output_list)
      end
    end

    context 'with two consistent features' do
      before(:example) do
        allow(word_search).to \
          receive(:find_unset_features_in_words)\
          .with([failed_winner_dup], grammar).and_return([unset_feat1, unset_feat2])
        allow(failed_winner_dup).to receive(:output).and_return(fw_output)
        allow(consistency_checker).to\
          receive(:mismatch_consistent?).and_return(true, true)
      end
      it 'raises a LearnEx exception' do
        expect do
          # actually construct the test object, and inject the test dependencies
          fewest_set_features =
            OTLearn::FewestSetFeatures.new(consistency_checker: consistency_checker,
            feature_value_pair_class: feature_value_pair_class,
                                           word_search: word_search)
          fewest_set_features.para_erc_learner = para_erc_learner
          @substep = fewest_set_features.run(output_list, grammar, prior_result)
        end.to raise_error(OTLearn::LearnEx)
      end
    end
  end

  context 'given an unsuccessful failed winner and a successful one' do
    let(:failed_winner_1) { double('failed_winner_1') }
    let(:failed_winner_1_dup) { double('failed_winner_1_dup') }
    let(:failed_winner_2) { double('failed_winner_2') }
    let(:failed_winner_2_dup) { double('failed_winner_2_dup') }
    let(:fw_output_1) { double('fw_output_1') }
    let(:fw_output_2) { double('fw_output_2') }
    let(:out_feat_instance1) { double('out_feat_instance1') }
    let(:out_feat_value1) { double('out_feat_value1') }
    let(:out_feat_instance2) { double('out_feat_instance2') }
    let(:out_feat_value2) { double('out_feat_value2') }
    let(:unset_feat1) { double('unset_feature_1') }
    let(:unset_feat2) { double('unset_feature_2') }
    let(:fv_pair1) { double('feature-value pair1') }
    let(:fv_pair2) { double('feature-value pair2') }
    before(:example) do
      # set up prior_result
      allow(prior_result).to receive(:failed_winners).
        and_return([failed_winner_1, failed_winner_2])
      allow(prior_result).to receive(:success_winners).and_return([])

      # Failed winner 1
      allow(failed_winner_1).to receive(:output).and_return(fw_output_1)
      allow(grammar).to receive(:parse_output)\
        .with(fw_output_1).and_return(failed_winner_1_dup)
      allow(failed_winner_1_dup).to receive(:output).and_return(fw_output_1)
      allow(consistency_checker).to receive(:mismatch_consistent?)
      allow(word_search).to receive(:find_unset_features_in_words)\
        .with([failed_winner_1_dup], grammar).and_return([unset_feat1])
      allow(failed_winner_1_dup).to \
        receive(:out_feat_corr_of_uf)\
        .with(unset_feat1).and_return(out_feat_instance1)
      allow(out_feat_instance1).to receive(:value).and_return(out_feat_value1)

      # Failed winner 2
      allow(failed_winner_2).to receive(:output).and_return(fw_output_2)
      allow(grammar).to receive(:parse_output).with(fw_output_2)\
        .and_return(failed_winner_2_dup)
      allow(failed_winner_2_dup).to receive(:output).and_return(fw_output_2)
      allow(consistency_checker).to receive(:mismatch_consistent?)
      allow(word_search).to receive(:find_unset_features_in_words).
        with([failed_winner_2_dup], grammar).and_return([unset_feat2])
      allow(failed_winner_2_dup).to \
        receive(:out_feat_corr_of_uf).with(unset_feat2)\
        .and_return(out_feat_instance2)
      allow(out_feat_instance2).to receive(:value).and_return(out_feat_value2)

      # The possible unset features and their behavior
      allow(unset_feat1).to receive(:value=).with(out_feat_value1)
      allow(unset_feat1).to receive(:value).and_return(out_feat_value1)
      allow(unset_feat1).to receive(:value=).with(nil)
      allow(unset_feat2).to receive(:value=).with(out_feat_value2)
      allow(unset_feat2).to receive(:value).and_return(out_feat_value2)
      allow(unset_feat2).to receive(:value=).with(nil)
      # a test double of FeatureValuePair for dependency injection
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat1, out_feat_value1).and_return(fv_pair1)
      allow(feature_value_pair_class).to \
        receive(:new).with(unset_feat2, out_feat_value2).and_return(fv_pair2)
      allow(fv_pair1).to receive(:feature_instance).and_return(unset_feat1)
      allow(fv_pair2).to receive(:feature_instance).and_return(unset_feat2)
      allow(fv_pair1).to receive(:set_to_alt_value)
      allow(fv_pair2).to receive(:set_to_alt_value)
    end
    context 'with the first failed winner inconsistent' do
      before(:example) do
        allow(consistency_checker).to receive(:mismatch_consistent?)\
          .with([fw_output_1], grammar).and_return(false)
        allow(consistency_checker).to receive(:mismatch_consistent?)\
          .with([fw_output_2], grammar).and_return(true)
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          OTLearn::FewestSetFeatures.new(consistency_checker: consistency_checker,
          feature_value_pair_class: feature_value_pair_class,
                                         word_search: word_search)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end
      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end
      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner_2
      end
      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end
      it 'sets the consistent unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat2
      end
      it 'checks for new ranking information for the unset feature' do
        expect(para_erc_learner).to \
          have_received(:run).with(unset_feat2, grammar, output_list)
      end
    end
    context 'with the first failed winner consistent' do
      before(:example) do
        allow(consistency_checker).to receive(:mismatch_consistent?)\
          .with([fw_output_1], grammar).and_return(true)
        allow(consistency_checker).to receive(:mismatch_consistent?)\
          .with([fw_output_2], grammar).and_return(true)
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          OTLearn::FewestSetFeatures.new(consistency_checker: consistency_checker,
          feature_value_pair_class: feature_value_pair_class,
                                         word_search: word_search)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end
      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end
      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner_1
      end
      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end
      it 'sets the consistent unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat1
      end
      it 'checks for new ranking information for the unset feature' do
        expect(para_erc_learner).to\
          have_received(:run).with(unset_feat1, grammar, output_list)
      end
    end
  end
end

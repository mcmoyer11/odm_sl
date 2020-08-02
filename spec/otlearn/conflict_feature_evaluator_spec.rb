# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/conflict_feature_evaluator'

RSpec.describe 'OTLearn::ConflictFeatureEvaluator' do
  let(:checker) { double('consistency checker') }
  let(:assigner) { double('input feature assigner') }
  let(:combiner) { double('feature value combiner') }
  let(:c_feat1) { double('conflict feature 1') }
  let(:c_feat2) { double('conflict feature 2') }
  let(:fvp_11) { double('feature value pair 11') }
  let(:fvp_12) { double('feature value pair 12') }
  let(:fvp_21) { double('feature value pair 21') }
  let(:fvp_22) { double('feature value pair 22') }
  let(:finst1) { double('feature instance 1') }
  let(:finst2) { double('feature instance 2') }
  let(:value11) { double('feature value 11') }
  let(:value12) { double('feature value 12') }
  let(:value21) { double('feature value 21') }
  let(:value22) { double('feature value 22') }
  let(:contrast_set) { double('contrast set') }
  let(:grammar) { double('grammar') }
  before(:example) do
    allow(fvp_11).to receive(:feature_instance).and_return(finst1)
    allow(fvp_12).to receive(:feature_instance).and_return(finst1)
    allow(fvp_11).to receive(:alt_value).and_return(value11)
    allow(fvp_12).to receive(:alt_value).and_return(value12)
    allow(fvp_21).to receive(:feature_instance).and_return(finst2)
    allow(fvp_22).to receive(:feature_instance).and_return(finst2)
    allow(fvp_21).to receive(:alt_value).and_return(value21)
    allow(fvp_22).to receive(:alt_value).and_return(value22)
    allow(assigner).to receive(:assign_input_features)
    @evaluator =
      OTLearn::ConflictFeatureEvaluator.new(input_assigner: assigner,
                                            feature_combiner: combiner)
    @evaluator.consistency_checker = checker
  end

  context 'given a single conflict feature with one consistent value' do
    before(:example) do
      @conflict_features = [c_feat1]
      allow(combiner).to receive(:feature_value_combinations)\
        .and_return([[fvp_11], [fvp_12]])
      allow(checker).to receive(:consistent?).and_return(true)
      @exists = @evaluator.run(@conflict_features, contrast_set, grammar)
    end
    it 'computes the combinations of conflict feature values' do
      expect(combiner).to have_received(:feature_value_combinations)\
        .with(@conflict_features)
    end
    it 'assigns the first value combination' do
      expect(assigner).to\
        have_received(:assign_input_features).with(finst1, value11,
                                                   contrast_set)
    end
    it 'does not assign the second value combination' do
      expect(assigner).not_to\
        have_received(:assign_input_features).with(finst1, value12,
                                                   contrast_set)
    end
    it 'checks the consistency of the first combination only' do
      expect(checker).to\
        have_received(:consistent?).with(contrast_set, grammar)\
                                   .exactly(1).times
    end
    it 'returns true' do
      expect(@exists).to be true
    end
  end
  context 'given a single conflict feature with no consistent values' do
    before(:example) do
      @conflict_features = [c_feat1]
      allow(combiner).to receive(:feature_value_combinations)\
        .and_return([[fvp_11], [fvp_12]])
      allow(checker).to receive(:consistent?).and_return(false, false)
      @exists = @evaluator.run(@conflict_features, contrast_set, grammar)
    end
    it 'computes the combinations of conflict feature values' do
      expect(combiner).to have_received(:feature_value_combinations)\
        .with(@conflict_features)
    end
    it 'assigns the first value combination' do
      expect(assigner).to\
        have_received(:assign_input_features).with(finst1, value11,
                                                   contrast_set)
    end
    it 'assigns the second value combination' do
      expect(assigner).to\
        have_received(:assign_input_features).with(finst1, value12,
                                                   contrast_set)
    end
    it 'checks the consistency of both combinations' do
      expect(checker).to\
        have_received(:consistent?).with(contrast_set, grammar)\
                                   .exactly(2).times
    end
    it 'returns false' do
      expect(@exists).to be false
    end
  end

  context 'given two conflict features with one consistent combination' do
    before(:example) do
      @conflict_features = [c_feat1, c_feat2]
      allow(combiner).to receive(:feature_value_combinations)\
        .and_return([[fvp_11, fvp_21], [fvp_11, fvp_22], [fvp_12, fvp_21],
                     [fvp_12, fvp_22]])
      allow(checker).to receive(:consistent?).and_return(false, false, true)
      @exists = @evaluator.run(@conflict_features, contrast_set, grammar)
    end
    it 'computes the combinations of conflict feature values' do
      expect(combiner).to have_received(:feature_value_combinations)\
        .with(@conflict_features)
    end
    it 'assigns value11 for 2 combinations' do
      expect(assigner).to\
        have_received(:assign_input_features)\
        .with(finst1, value11, contrast_set).exactly(2).times
    end
    it 'assigns value12 for 1 combination' do
      expect(assigner).to\
        have_received(:assign_input_features)\
        .with(finst1, value12, contrast_set).exactly(1).time
    end
    it 'assigns value21 for 2 combinations' do
      expect(assigner).to\
        have_received(:assign_input_features)\
        .with(finst2, value21, contrast_set).exactly(2).times
    end
    it 'assigns value22 for 1 combination' do
      expect(assigner).to\
        have_received(:assign_input_features)\
        .with(finst2, value22, contrast_set).exactly(1).time
    end
    it 'checks the consistency of three combinations' do
      expect(checker).to\
        have_received(:consistent?).with(contrast_set, grammar)\
                                   .exactly(3).times
    end
    it 'returns true' do
      expect(@exists).to be true
    end
  end
end

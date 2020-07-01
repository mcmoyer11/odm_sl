# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/induction_step'
require 'otlearn/otlearn'

RSpec.describe 'OTLearn::InductionStep' do
  let(:test_result) { double('test_result') }
  context 'with a changed grammar that is not all correct' do
    before(:example) do
      allow(test_result).to receive(:all_correct?).and_return(false)
      @step = OTLearn::InductionStep.new(OTLearn::FEWEST_SET_FEATURES, test_result, true)
    end
    it 'indicates a step type of INDUCTION' do
      expect(@step.step_type).to eq OTLearn::INDUCTION
    end
    it 'indicates a step subtype of FewestSetFeatures' do
      expect(@step.step_subtype).to eq OTLearn::FEWEST_SET_FEATURES
    end
    it 'indicates that the grammar has changed' do
      expect(@step.changed?).to be true
    end
    it 'returns the grammar test result' do
      expect(@step.test_result).to eq test_result
    end
    it 'indicates that not all data are correctly reproduced' do
      expect(@step.all_correct?).to be false
    end
  end
  context 'with an unchanged grammar that is all correct' do
    before(:example) do
      allow(test_result).to receive(:all_correct?).and_return(true)
      @step = OTLearn::InductionStep.new(OTLearn::MAX_MISMATCH_RANKING, test_result, false)
    end
    it 'indicates a step type of INDUCTION' do
      expect(@step.step_type).to eq OTLearn::INDUCTION
    end
    it 'indicates a step subtype of MaxMismatchRanking' do
      expect(@step.step_subtype).to eq OTLearn::MAX_MISMATCH_RANKING
    end
    it 'indicates that the grammar has not changed' do
      expect(@step.changed?).to be_falsey
    end
    it 'returns the grammar test result' do
      expect(@step.test_result).to eq test_result
    end
    it 'indicates that all data are correctly reproduced' do
      expect(@step.all_correct?).to be true
    end
  end
end

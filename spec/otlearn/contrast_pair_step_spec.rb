# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/contrast_pair_step'
require 'otlearn/otlearn'

RSpec.describe 'OTLearn::ContrastPairStep' do
  let(:test_result) { double('test_result') }
  let(:contrast_pair) { double('contrast_pair') }
  context 'with a changed grammar that is not all correct' do
    before(:example) do
      allow(test_result).to receive(:all_correct?).and_return(false)
      @step = OTLearn::ContrastPairStep.new(test_result, true, contrast_pair)
    end
    it 'indicates a step type of CONTRAST_PAIR' do
      expect(@step.step_type).to eq OTLearn::CONTRAST_PAIR
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
    it 'provides the contrast pair' do
      expect(@step.contrast_pair).to eq contrast_pair
    end
  end
  context 'with an unchanged grammar that is all correct' do
    before(:example) do
      allow(test_result).to receive(:all_correct?).and_return(true)
      @step = OTLearn::ContrastPairStep.new(test_result, false, contrast_pair)
    end
    it 'indicates a step type of SINGLE_FORM' do
      expect(@step.step_type).to eq OTLearn::CONTRAST_PAIR
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
    it 'provides the contrast pair' do
      expect(@step.contrast_pair).to eq contrast_pair
    end
  end
end

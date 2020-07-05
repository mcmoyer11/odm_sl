# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/fsf_substep'
require 'otlearn/otlearn'

RSpec.describe 'OTLearn::FsfSubstep' do
  let(:newly_set_feature) { double('newly_set_feature') }
  let(:failed_winner) { double('failed_winner') }
  context 'with no newly set features' do
    before(:example) do
      set_features = []
      @substep = OTLearn::FsfSubstep.new(set_features, failed_winner)
    end
    it 'indicates a subtype of FewestSetFeatures' do
      expect(@substep.subtype).to eq OTLearn::FEWEST_SET_FEATURES
    end
    it 'returns an empty list of newly set features' do
      expect(@substep.newly_set_features).to be_empty
    end
    it 'returns the failed winner' do
      expect(@substep.failed_winner).to eq failed_winner
    end
    it 'indicates that the grammar has not changed' do
      expect(@substep.changed?).to be false
    end
  end
  context 'with one newly set feature' do
    before(:example) do
      set_features = [newly_set_feature]
      @substep = OTLearn::FsfSubstep.new(set_features, failed_winner)
    end
    it 'indicates a subtype of FewestSetFeatures' do
      expect(@substep.subtype).to eq OTLearn::FEWEST_SET_FEATURES
    end
    it 'returns the list of newly set features' do
      expect(@substep.newly_set_features).to contain_exactly(newly_set_feature)
    end
    it 'returns the failed winner' do
      expect(@substep.failed_winner).to eq failed_winner
    end
    it 'indicates that the grammar has changed' do
      expect(@substep.changed?).to be true
    end
  end
end

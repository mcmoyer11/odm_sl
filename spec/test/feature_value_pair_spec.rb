# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'feature_value_pair'

RSpec.describe 'FeatureValuePair' do
  let(:f_inst) { double('feature instance') }
  let(:feature) { double('feature') }
  let(:value) { double('value') }
  let(:f_type) { double('feature type') }
  before(:example) do
    allow(f_inst).to receive(:feature).and_return(feature)
    allow(feature).to receive(:type).and_return(f_type)
  end

  context 'given a feature instance and a valid value' do
    before(:example) do
      allow(feature).to receive(:each_value).and_yield(value)
      @fvp = FeatureValuePair.new(f_inst, value)
    end
    it 'returns the feature instance' do
      expect(@fvp.feature_instance).to eq f_inst
    end
    it 'returns the given value' do
      expect(@fvp.alt_value).to eq value
    end
    context 'when set_to_alt_value is called' do
      before(:example) do
        allow(feature).to receive(:value=)
        @fvp.set_to_alt_value
      end
      it 'it sets the value' do
        expect(feature).to have_received(:value=).with(value)
      end
    end
  end
  context 'given an invalid value' do
    let(:other_value) { double('other_value') }
    before(:example) do
      allow(feature).to receive(:each_value).and_yield(other_value)
    end
    it 'raises a RuntimeError' do
      expect { FeatureValuePair.new(f_inst, value) }.to\
        raise_error(RuntimeError)
    end
  end

  context 'calling .all_values_pairs'
end

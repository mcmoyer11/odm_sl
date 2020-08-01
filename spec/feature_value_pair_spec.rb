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
      allow(feature).to receive(:valid_value?).with(value).and_return(true)
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
      allow(feature).to receive(:valid_value?).with(value).and_return(false)
    end
    it 'raises a RuntimeError' do
      expect { FeatureValuePair.new(f_inst, value) }.to\
        raise_error(RuntimeError)
    end
  end

  context '.all_values_pairs' do
    let(:finst1) { double('feature instance 1') }
    let(:feat1) { double('feature 1') }
    let(:value11) { double('feature value 11') }
    let(:value12) { double('feature value 12') }
    let(:type1) { double('feature type 1') }
    before(:example) do
      allow(finst1).to receive(:feature).and_return(feat1)
      allow(feat1).to receive(:each_value).and_yield(value11)\
                                          .and_yield(value12)
      allow(feat1).to receive(:type).and_return(type1)
      allow(feat1).to receive(:valid_value?).with(value11).and_return(true)
      allow(feat1).to receive(:valid_value?).with(value12).and_return(true)
    end
    context 'with one feature' do
      before(:example) do
        feature_instance_list = [finst1]
        @avp_list = FeatureValuePair.all_values_pairs(feature_instance_list)
        @fvp_list = @avp_list[0]
      end
      it 'returns a list of entries for one feature' do
        expect(@avp_list.size).to eq(1)
      end
      it 'returns a pair list of two values for the feature' do
        expect(@fvp_list.size).to eq(2)
      end
    end
  end
end

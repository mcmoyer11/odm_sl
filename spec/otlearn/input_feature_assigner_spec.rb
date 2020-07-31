# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/input_feature_assigner'

RSpec.describe 'OTLearn::InputFeatureAssigner' do
  let(:f_uf_inst) { double('UF feature instance') }
  let(:uf_el) { double('UF element') }
  let(:uf_feat) { double('UF feature') }
  let(:assigned_value) { double('assigned value') }
  let(:word1) { double('word1') }
  let(:word2) { double('word2') }
  let(:in_el1) { double('in element 1') }
  let(:in_el2) { double('in element 2') }
  let(:in_feat1) { double('in feature 1') }
  let(:in_feat2) { double('in feature 2') }
  let(:f_type) { double('feature type') }
  before(:example) do
    allow(f_uf_inst).to receive(:element).and_return(uf_el)
    allow(f_uf_inst).to receive(:feature).and_return(uf_feat)
    allow(uf_feat).to receive(:type).and_return(f_type)
    allow(in_feat1).to receive(:value=)
    allow(in_feat2).to receive(:value=)
    allow(word1).to receive(:eval)
    allow(word2).to receive(:eval)
    @assigner = OTLearn::InputFeatureAssigner.new
  end

  context 'given two words with the feature' do
    before(:example) do
      allow(word1).to receive(:ui_in_corr).with(uf_el).and_return(in_el1)
      allow(word2).to receive(:ui_in_corr).with(uf_el).and_return(in_el2)
      allow(in_el1).to receive(:get_feature).with(f_type)\
                                            .and_return(in_feat1)
      allow(in_el2).to receive(:get_feature).with(f_type)\
                                            .and_return(in_feat2)
      word_list = [word1, word2]
      @return_value =
        @assigner.assign_input_features(f_uf_inst, assigned_value, word_list)
    end
    it 'assigns the input value to the first word' do
      expect(in_feat1).to have_received(:value=).with(assigned_value)
    end
    it 're-evaluates the constraint violations for the first word' do
      expect(word1).to have_received(:eval)
    end
    it 'assigns the input value to the second word' do
      expect(in_feat2).to have_received(:value=).with(assigned_value)
    end
    it 're-evaluates the constraint violations for the second word' do
      expect(word2).to have_received(:eval)
    end
  end

  context 'given a word without and a word with the feature' do
    before(:example) do
      allow(word1).to receive(:ui_in_corr).with(uf_el).and_return(nil)
      allow(word2).to receive(:ui_in_corr).with(uf_el).and_return(in_el2)
      allow(in_el1).to receive(:get_feature).with(f_type)\
                                            .and_return(in_feat1)
      allow(in_el2).to receive(:get_feature).with(f_type)\
                                            .and_return(in_feat2)
      word_list = [word1, word2]
      @return_value =
        @assigner.assign_input_features(f_uf_inst, assigned_value, word_list)
    end
    it 'does not assign the input value to the first word' do
      expect(in_feat1).not_to have_received(:value=)
    end
    it 'does not re-evaluate the constraint violations for the first word' do
      expect(word1).not_to have_received(:eval)
    end
    it 'assigns the input value to the second word' do
      expect(in_feat2).to have_received(:value=).with(assigned_value)
    end
    it 're-evaluates the constraint violations for the second word' do
      expect(word2).to have_received(:eval)
    end
  end
end

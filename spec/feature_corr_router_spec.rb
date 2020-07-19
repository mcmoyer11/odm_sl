# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'feature_corr_router'

RSpec.describe 'FeatureCorrRouter' do
  let(:fi_class) { double('feature instance class') }
  let(:word) { double('word') }
  let(:io_corr) { double('io_corr') }
  let(:result_finst) { double('result feature instance') }
  let(:output) { double('output') }
  let(:out_finst) { double('output feature instance') }
  let(:out_element) { double('out_element') }
  let(:out_feature) { double('out_feature') }
  let(:ftype) { double('feature type') }
  let(:input) { double('input') }
  let(:in_finst) { double('input feature instance') }
  let(:in_element) { double('in_element') }
  let(:in_feature) { double('in_feature') }
  before(:example) do
    allow(fi_class).to receive(:new)
    allow(fi_class).to receive(:new).and_return(result_finst)
    allow(word).to receive(:io_corr).and_return(io_corr)
    allow(word).to receive(:output).and_return(output)
    allow(word).to receive(:input).and_return(input)
    @router = FeatureCorrRouter.new(feat_inst_class: fi_class)
  end

  context 'out -> in' do
    before(:example) do
      allow(out_finst).to receive(:element).and_return(out_element)
      allow(out_finst).to receive(:feature).and_return(out_feature)
      allow(out_feature).to receive(:type).and_return(ftype)
      allow(output).to receive(:member?).and_return(true)
      allow(io_corr).to receive(:in_corr).and_return(in_element)
      allow(in_element).to receive(:get_feature).and_return(in_feature)
      @router.word = word
      @finst = @router.in_feat_corr_of_out(out_finst)
    end
    it 'ensures the parameter belongs to the output' do
      expect(output).to have_received(:member?).with(out_element)
    end
    it 'gets the corresponding input element' do
      expect(io_corr).to have_received(:in_corr).with(out_element)
    end
    it 'gets the input feature' do
      expect(in_element).to have_received(:get_feature).with(ftype)
    end
    it 'creates a new feature instance' do
      expect(fi_class).to have_received(:new).with(in_element, in_feature)
    end
    it 'returns the new feature instance' do
      expect(@finst).to eq result_finst
    end
  end
  context 'in -> out' do
    before(:example) do
      allow(in_finst).to receive(:element).and_return(in_element)
      allow(in_finst).to receive(:feature).and_return(in_feature)
      allow(in_feature).to receive(:type).and_return(ftype)
      allow(input).to receive(:member?).and_return(true)
      allow(io_corr).to receive(:out_corr).and_return(out_element)
      allow(out_element).to receive(:get_feature).and_return(out_feature)
      @router.word = word
      @finst = @router.out_feat_corr_of_in(in_finst)
    end
    it 'ensures the parameter belongs to the input' do
      expect(input).to have_received(:member?).with(in_element)
    end
    it 'gets the corresponding output element' do
      expect(io_corr).to have_received(:out_corr).with(in_element)
    end
    it 'gets the output feature' do
      expect(out_element).to have_received(:get_feature).with(ftype)
    end
    it 'creates a new feature instance' do
      expect(fi_class).to have_received(:new).with(out_element, out_feature)
    end
    it 'returns the new feature instance' do
      expect(@finst).to eq result_finst
    end
  end
end

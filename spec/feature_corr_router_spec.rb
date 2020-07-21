# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'feature_corr_router'

RSpec.describe 'FeatureCorrRouter' do
  let(:fi_class) { double('feature instance class') }
  let(:word) { double('word') }
  let(:result_finst) { double('result feature instance') }
  let(:ftype) { double('feature type') }
  let(:output) { double('output') }
  let(:out_finst) { double('output feature instance') }
  let(:out_element) { double('out_element') }
  let(:out_feature) { double('out_feature') }
  let(:input) { double('input') }
  let(:in_finst) { double('input feature instance') }
  let(:in_element) { double('in_element') }
  let(:in_feature) { double('in_feature') }
  let(:uf_finst) { double('uf feature instance') }
  let(:uf_element) { double('uf_element') }
  let(:uf_feature) { double('uf_feature') }
  before(:example) do
    allow(fi_class).to receive(:new)
    allow(word).to receive(:output).and_return(output)
    allow(word).to receive(:input).and_return(input)
    allow(out_finst).to receive(:element).and_return(out_element)
    allow(out_finst).to receive(:feature).and_return(out_feature)
    allow(out_element).to receive(:get_feature).and_return(out_feature)
    allow(out_feature).to receive(:type).and_return(ftype)
    allow(in_finst).to receive(:element).and_return(in_element)
    allow(in_finst).to receive(:feature).and_return(in_feature)
    allow(in_feature).to receive(:type).and_return(ftype)
    allow(in_element).to receive(:get_feature).and_return(in_feature)
    allow(uf_finst).to receive(:element).and_return(uf_element)
    allow(uf_finst).to receive(:feature).and_return(uf_feature)
    allow(uf_feature).to receive(:type).and_return(ftype)
    allow(uf_element).to receive(:get_feature).and_return(uf_feature)
    @router = FeatureCorrRouter.new(feat_inst_class: fi_class)
  end

  context 'out -> in' do
    context 'with an input correspondent' do
      before(:example) do
        allow(output).to receive(:member?).and_return(true)
        allow(word).to receive(:io_in_corr).and_return(in_element)
        allow(fi_class).to receive(:new).and_return(result_finst)
        @router.word = word
        @finst = @router.in_feat_corr_of_out(out_finst)
      end
      it 'ensures the parameter belongs to the output' do
        expect(output).to have_received(:member?).with(out_element)
      end
      it 'gets the corresponding input element' do
        expect(word).to have_received(:io_in_corr).with(out_element)
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
    context 'with non-member output finst' do
      before(:example) do
        allow(output).to receive(:member?).and_return(false)
        @router.word = word
        @finst = @router.in_feat_corr_of_out(out_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
    context 'with no input correspondent' do
      before(:example) do
        allow(output).to receive(:member?).and_return(true)
        allow(word).to receive(:io_in_corr).and_return(nil)
        @router.word = word
        @finst = @router.in_feat_corr_of_out(out_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
  end

  context 'in -> out' do
    context 'with an output correspondent' do
      before(:example) do
        allow(input).to receive(:member?).and_return(true)
        allow(word).to receive(:io_out_corr).and_return(out_element)
        allow(fi_class).to receive(:new).and_return(result_finst)
        @router.word = word
        @finst = @router.out_feat_corr_of_in(in_finst)
      end
      it 'ensures the parameter belongs to the input' do
        expect(input).to have_received(:member?).with(in_element)
      end
      it 'gets the corresponding output element' do
        expect(word).to have_received(:io_out_corr).with(in_element)
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
    context 'with non-member input finst' do
      before(:example) do
        allow(input).to receive(:member?).and_return(false)
        @router.word = word
        @finst = @router.out_feat_corr_of_in(in_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
    context 'with no output correspondent' do
      before(:example) do
        allow(input).to receive(:member?).and_return(true)
        allow(word).to receive(:io_out_corr).and_return(nil)
        @router.word = word
        @finst = @router.out_feat_corr_of_in(in_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
  end

  context 'in -> uf' do
    context 'with a UF correspondent' do
      before(:example) do
        allow(input).to receive(:member?).and_return(true)
        allow(word).to receive(:ui_under_corr).and_return(uf_element)
        allow(fi_class).to receive(:new).and_return(result_finst)
        @router.word = word
        @finst = @router.uf_feat_corr_of_in(in_finst)
      end
      it 'ensures the parameter belongs to the input' do
        expect(input).to have_received(:member?).with(in_element)
      end
      it 'gets the corresponding uf element' do
        expect(word).to have_received(:ui_under_corr).with(in_element)
      end
      it 'gets the uf feature' do
        expect(uf_element).to have_received(:get_feature).with(ftype)
      end
      it 'creates a new feature instance' do
        expect(fi_class).to have_received(:new).with(uf_element, uf_feature)
      end
      it 'returns the new feature instance' do
        expect(@finst).to eq result_finst
      end
    end
    context 'with non-member input finst' do
      before(:example) do
        allow(input).to receive(:member?).and_return(false)
        @router.word = word
        @finst = @router.uf_feat_corr_of_in(in_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
    context 'with no UF correspondent' do
      before(:example) do
        allow(input).to receive(:member?).and_return(true)
        allow(word).to receive(:ui_under_corr).and_return(nil)
        @router.word = word
        @finst = @router.uf_feat_corr_of_in(in_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
  end

  context 'uf -> in' do
    context 'with an input correspondent' do
      before(:example) do
        allow(word).to receive(:ui_in_corr?).and_return(true)
        allow(word).to receive(:ui_in_corr).and_return(in_element)
        allow(fi_class).to receive(:new).and_return(result_finst)
        @router.word = word
        @finst = @router.in_feat_corr_of_uf(uf_finst)
      end
      it 'ensures the parameter belongs to the UF' do
        expect(word).to have_received(:ui_in_corr?).with(uf_element)
      end
      it 'gets the corresponding input element' do
        expect(word).to have_received(:ui_in_corr).with(uf_element)
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
    context 'with non-member UF finst' do
      before(:example) do
        allow(word).to receive(:ui_in_corr?).and_return(false)
        @router.word = word
        @finst = @router.in_feat_corr_of_uf(uf_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
    context 'with no input correspondent' do
      before(:example) do
        allow(word).to receive(:ui_in_corr?).and_return(true)
        allow(word).to receive(:ui_in_corr).and_return(nil)
        @router.word = word
        @finst = @router.in_feat_corr_of_uf(uf_finst)
      end
      it 'returns nil' do
        expect(@finst).to be_nil
      end
    end
  end

  context 'uf -> out' do
    context 'with a corresponding input finst' do
      before(:example) do
        allow(word).to receive(:ui_in_corr?).and_return(true)
        allow(word).to receive(:ui_in_corr).and_return(in_element)
        allow(input).to receive(:member?).and_return(true)
        allow(word).to receive(:io_out_corr).and_return(out_element)
        allow(fi_class).to receive(:new).with(in_element, in_feature)\
                                        .and_return(in_finst)
        allow(fi_class).to receive(:new).with(out_element, out_feature)\
                                        .and_return(result_finst)
        @router.word = word
        @finst = @router.out_feat_corr_of_uf(uf_finst)
      end
      it 'creates a new input feature instance' do
        expect(fi_class).to have_received(:new).with(in_element, in_feature)
      end
      it 'creates a new output feature instance' do
        expect(fi_class).to have_received(:new).with(out_element, out_feature)
      end
      it 'returns the new feature instance' do
        expect(@finst).to eq result_finst
      end
    end
  end
end

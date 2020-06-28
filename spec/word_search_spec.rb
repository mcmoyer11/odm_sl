# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'word_search'

RSpec.describe 'WordSearch' do
  before(:example) do
    @ws = WordSearch.new
  end

  context '#find_unfaithful' do
    let(:uf_feat) { double('feature') }
    let(:uf_feat_value) { double('uf_feat_value') }
    let(:word1) { double('word1') }
    let(:out_feat1) { double('out_feat1') }
    let(:out_feat1_value) { double('out_feat1_value') }
    let(:word2) { double('word2') }
    let(:out_feat2) { double('out_feat2') }
    let(:out_feat2_value) { double('out_feat2_value') }
    before(:example) do
      allow(word1).to receive(:out_feat_corr_of_uf).and_return(out_feat1)
      allow(word2).to receive(:out_feat_corr_of_uf).and_return(out_feat2)
      allow(uf_feat).to receive(:value).and_return(uf_feat_value)
      allow(out_feat1).to receive(:value).and_return(out_feat1_value)
      allow(out_feat2).to receive(:value).and_return(out_feat2_value)
    end
    context 'with no unfaithful words' do
      before(:example) do
        allow(out_feat1).to receive(:nil?).and_return(false)
        allow(uf_feat_value).to\
          receive(:!=).with(out_feat1_value).and_return(false)
        words = [word1]
        @cwords = @ws.find_unfaithful(uf_feat, words)
      end
      it 'returns an empty list' do
        expect(@cwords).to be_empty
      end
    end
    context 'with one faithful and one unfaithful word' do
      before(:example) do
        allow(out_feat1).to receive(:nil?).and_return(false)
        allow(out_feat2).to receive(:nil?).and_return(false)
        allow(uf_feat_value).to\
          receive(:!=).with(out_feat1_value).and_return(false)
        allow(uf_feat_value).to\
          receive(:!=).with(out_feat2_value).and_return(true)
        words = [word1, word2]
        @cwords = @ws.find_unfaithful(uf_feat, words)
      end
      it 'returns a list with the unfaithful word' do
        expect(@cwords).to eq [word2]
      end
    end
    context 'with one unfaithful word and one with no output correspondent' do
      before(:example) do
        allow(out_feat1).to receive(:nil?).and_return(false)
        allow(out_feat2).to receive(:nil?).and_return(true)
        allow(uf_feat_value).to\
          receive(:!=).with(out_feat1_value).and_return(true)
        words = [word1, word2]
        @cwords = @ws.find_unfaithful(uf_feat, words)
      end
      it 'returns a list with the unfaithful word' do
        expect(@cwords).to eq [word1]
      end
    end
  end
end

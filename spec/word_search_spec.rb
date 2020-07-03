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

  context 'morphemes_to_words' do
    let(:word1) { double('word1') }
    let(:mw1) { double('morphword1') }
    let(:word2) { double('word2') }
    let(:mw2) { double('morphword2') }
    let(:morph1) { double('morpheme1') }
    let(:morph2) { double('morpheme2') }
    let(:morph3) { double('morpheme3') }
    before(:example) do
      allow(word1).to receive(:morphword).and_return(mw1)
      allow(word2).to receive(:morphword).and_return(mw2)
    end
    context 'with one word and one morpheme' do
      before(:example) do
        allow(mw1).to receive(:each).and_yield(morph1)
        @mwhash = @ws.morphemes_to_words([word1])
      end
      it 'gets the morphemes for word1' do
        expect(word1).to have_received(:morphword)
      end
      it 'maps morpheme1 to [word1]' do
        expect(@mwhash[morph1]).to contain_exactly(word1)
      end
    end
    context 'with two words sharing a morpheme' do
      before(:example) do
        allow(mw1).to receive(:each).and_yield(morph1).and_yield(morph2)
        allow(mw2).to receive(:each).and_yield(morph1).and_yield(morph3)
        @mwhash = @ws.morphemes_to_words([word1, word2])
      end
      it 'maps morpheme1 to [word1, word2]' do
        expect(@mwhash[morph1]).to contain_exactly(word1, word2)
      end
      it 'maps morpheme2 to [word1]' do
        expect(@mwhash[morph2]).to contain_exactly(word1)
      end
      it 'maps morpheme3 to [word2]' do
        expect(@mwhash[morph3]).to contain_exactly(word2)
      end
    end
  end
end

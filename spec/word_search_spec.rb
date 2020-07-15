# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'word_search'

RSpec.describe 'WordSearch' do
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
      @ws = WordSearch.new
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
      @ws = WordSearch.new
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

  context 'find_unset_features_of_morpheme' do
    let(:finst_class) { double('feature instance class') }
    let(:morph) { double('morpheme') }
    let(:grammar) { double('grammar') }
    let(:under_form) { double('underlying form') }
    let(:s1) { double('segment1') }
    let(:s2) { double('segment2') }
    let(:f1_1) { double('feature1_1') }
    let(:f1_2) { double('feature1_2') }
    let(:f2_1) { double('feature2_1') }
    let(:f2_2) { double('feature2_2') }
    let(:inst1_1) { double('feat instance 1_1') }
    let(:inst1_2) { double('feat instance 1_2') }
    let(:inst2_1) { double('feat instance 2_1') }
    let(:inst2_2) { double('feat instance 2_2') }
    before(:example) do
      allow(grammar).to receive(:get_uf).with(morph).and_return(under_form)
      allow(under_form).to receive(:each).and_yield(s1).and_yield(s2)
      allow(s1).to receive(:each_feature).and_yield(f1_1).and_yield(f1_2)
      allow(s2).to receive(:each_feature).and_yield(f2_1).and_yield(f2_2)
      allow(finst_class).to receive(:new).with(s1, f1_1).and_return(inst1_1)
      allow(finst_class).to receive(:new).with(s1, f1_2).and_return(inst1_2)
      allow(finst_class).to receive(:new).with(s2, f2_1).and_return(inst2_1)
      allow(finst_class).to receive(:new).with(s2, f2_2).and_return(inst2_2)
      @ws = WordSearch.new(feat_inst_class: finst_class)
    end
    context 'with one unset feature' do
      before(:example) do
        allow(f1_1).to receive(:unset?).and_return(false)
        allow(f1_2).to receive(:unset?).and_return(true)
        allow(f2_1).to receive(:unset?).and_return(false)
        allow(f2_2).to receive(:unset?).and_return(false)
        @unset_features =
          @ws.find_unset_features_of_morpheme(morph, grammar)
      end
      it 'returns a list with the unset feature' do
        expect(@unset_features).to contain_exactly(inst1_2)
      end
    end
    context 'with no unset features' do
      before(:example) do
        allow(f1_1).to receive(:unset?).and_return(false)
        allow(f1_2).to receive(:unset?).and_return(false)
        allow(f2_1).to receive(:unset?).and_return(false)
        allow(f2_2).to receive(:unset?).and_return(false)
        @unset_features =
          @ws.find_unset_features_of_morpheme(morph, grammar)
      end
      it 'returns an empty list' do
        expect(@unset_features).to be_empty
      end
    end
    context 'with two unset features' do
      before(:example) do
        allow(f1_1).to receive(:unset?).and_return(true)
        allow(f1_2).to receive(:unset?).and_return(false)
        allow(f2_1).to receive(:unset?).and_return(false)
        allow(f2_2).to receive(:unset?).and_return(true)
        @unset_features =
          @ws.find_unset_features_of_morpheme(morph, grammar)
      end
      it 'returns a list of both features' do
        expect(@unset_features).to contain_exactly(inst1_1, inst2_2)
      end
    end
  end

  context 'conflicting_output_values?' do
    let(:uf_feat) { double('UF feature') }
    let(:word1) { double('word1') }
    let(:word2) { double('word2') }
    let(:out_feat1) { double('out_feat1') }
    let(:out_feat2) { double('out_feat2') }
    before(:example) do
      allow(word1).to receive(:out_feat_corr_of_uf).with(uf_feat)\
                                                   .and_return(out_feat1)
      allow(word2).to receive(:out_feat_corr_of_uf).with(uf_feat)\
                                                   .and_return(out_feat2)
      @ws = WordSearch.new
    end
    context 'given conflictng output values' do
      before(:example) do
        allow(out_feat1).to receive(:nil?).and_return(false)
        allow(out_feat2).to receive(:nil?).and_return(false)
        allow(out_feat1).to receive(:value).and_return('value A')
        allow(out_feat2).to receive(:value).and_return('value B')
        word_list = [word1, word2]
        @conflict = @ws.conflicting_output_values?(uf_feat, word_list)
      end
      it 'returns true' do
        expect(@conflict).to be true
      end
    end
    context 'given non-conflicting output values' do
      before(:example) do
        allow(out_feat1).to receive(:nil?).and_return(false)
        allow(out_feat2).to receive(:nil?).and_return(false)
        allow(out_feat1).to receive(:value).and_return('value A')
        allow(out_feat2).to receive(:value).and_return('value A')
        word_list = [word1, word2]
        @conflict = @ws.conflicting_output_values?(uf_feat, word_list)
      end
      it 'returns false' do
        expect(@conflict).to be false
      end
    end
    context 'given a word lacking an output correspondent' do
      before(:example) do
        allow(out_feat1).to receive(:nil?).and_return(true)
        allow(out_feat2).to receive(:nil?).and_return(false)
        allow(out_feat1).to receive(:value).and_return('value X')
        allow(out_feat2).to receive(:value).and_return('value A')
        word_list = [word1, word2]
        @conflict = @ws.conflicting_output_values?(uf_feat, word_list)
      end
      it 'it ignores that word' do
        expect(@conflict).to be false
      end
    end
  end
end

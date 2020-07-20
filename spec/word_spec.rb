# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'word'

RSpec.describe Word do
  let(:system) { double('system') }
  let(:candidate_class) { double('candidate_class') }
  let(:router) { double('feature corr router') }
  let(:candidate) { double('candidate') }
  let(:input) { double('input') }
  let(:output) { double('output') }
  before(:example) do
    allow(candidate_class).to receive(:new).and_return(candidate)
    allow(system).to receive(:constraints)
    allow(candidate).to receive(:input).and_return(input)
    allow(candidate).to receive(:output).and_return(output)
    allow(router).to receive(:word=)
  end

  context 'given empty input and output' do
    before(:example) do
      @word = Word.new(system, input, output,
                       candidate_class: candidate_class, corr_router: router)
    end
    it 'gives the input' do
      expect(@word.input).to eq input
    end
    it 'gives the output' do
      expect(@word.output).to eq output
    end
  end

  context 'with a single input segment with one set and one unset feature' do
    let(:finst_1) { double('finst_1') }
    let(:finst_2) { double('finst_2') }
    let(:in_feat1) { double('in_feat1') }
    let(:in_feat2) { double('in_feat2') }
    let(:out_value2) { double('out_value2') }
    let(:out_finst2) { double('out feature instance 2') }
    before(:example) do
      allow(input).to receive(:each_feature).and_yield(finst_1) \
                                            .and_yield(finst_2)
      allow(finst_1).to receive(:feature).and_return(in_feat1)
      allow(finst_2).to receive(:feature).and_return(in_feat2)
      allow(in_feat1).to receive(:unset?).and_return(false)
      allow(in_feat2).to receive(:unset?).and_return(true)
      allow(router).to receive(:out_feat_corr_of_in).with(finst_2)\
                                                    .and_return(out_finst2)
      @word = Word.new(system, input, output,
                       candidate_class: candidate_class, corr_router: router)
      allow(@word).to receive(:eval)
    end
    context '#match_input_to_output' do
      before(:example) do
        allow(out_finst2).to receive(:value).and_return(out_value2)
        allow(finst_2).to receive(:value=).with(out_value2)
        @ret_value = @word.match_input_to_output!
      end
      it 'assigns the unset feature the value of the output correspondent' do
        expect(finst_2).to have_received(:value=).with(out_value2)
      end
      it 're-evaluates the constraint violations' do
        expect(@word).to have_received(:eval)
      end
      it 'returns a reference to the word' do
        expect(@ret_value).to eq @word
      end
    end
    context '#mismatch_input_to_output' do
      let(:unset_feat_oppout_value) { double('unset_feat_oppout_value') }
      before(:example) do
        allow(out_finst2).to receive(:value).and_return(out_value2)
        allow(finst_2).to receive(:value=).with(unset_feat_oppout_value)
        allow(in_feat2).to receive(:each_value)\
          .and_yield(out_value2)\
          .and_yield(unset_feat_oppout_value)
        @ret_value = @word.mismatch_input_to_output!
      end
      it 'assigns the value opposite the output correspondent' do
        expect(finst_2).to\
          have_received(:value=).with(unset_feat_oppout_value)
      end
      it 're-evaluates the constraint violations' do
        expect(@word).to have_received(:eval)
      end
      it 'returns a reference to the word' do
        expect(@ret_value).to eq @word
      end
    end
  end

  context 'with a single input segment with a suprabinary feature' do
    let(:finst_1) { double('finst_1') }
    let(:suprabinary_feat) { double('suprabinary_feat') }
    let(:suprabinary_feat_value1) { double('suprabinary_feat_value1') }
    let(:suprabinary_feat_value2) { double('suprabinary_feat_value2') }
    let(:suprabinary_feat_value3) { double('suprabinary_feat_value3') }
    before(:example) do
      allow(input).to receive(:each_feature).and_yield(finst_1)
      allow(finst_1).to receive(:feature).and_return(suprabinary_feat)
      allow(suprabinary_feat).to receive(:unset?).and_return(true)
      @word = Word.new(system, input, output,
                       candidate_class: candidate_class, corr_router: router)
      allow(@word).to receive(:eval)
    end
    context '#mismatch_input_to_output!' do
      before(:example) do
        allow(suprabinary_feat).to receive(:each_value)\
          .and_yield(suprabinary_feat_value1)\
          .and_yield(suprabinary_feat_value2)\
          .and_yield(suprabinary_feat_value3)
      end
      it 'raises a RuntimeError indicating a suprabinary feature' do
        expect { @word.mismatch_input_to_output! }.to raise_error(RuntimeError)
      end
    end
  end

  context 'given two words with distinct but equivalent candidates' do
    let(:candidate2) { double('candidate2') }
    let(:input2) { double('input2') }
    let(:output2) { double('output2') }
    before(:example) do
      allow(candidate_class).to receive(:new).and_return(candidate, candidate2)
      allow(candidate2).to receive(:input).and_return(input2)
      allow(candidate2).to receive(:output).and_return(output2)
      allow(candidate).to receive(:==).with(candidate2).and_return(true)
      @word1 = Word.new(system, input, output,
                        candidate_class: candidate_class, corr_router: router)
      @word2 = Word.new(system, input2, output2,
                        candidate_class: candidate_class, corr_router: router)
    end
    it 'they are equivalent' do
      expect(@word1 == @word2).to be true
    end
  end

  # Because Word#dup constructs a new Word internally, the testing will
  # involve some other dependent classes.
  context 'its duplicate' do
    let(:in_1) { double('in_1') }
    let(:in_2) { double('in_2') }
    let(:out_1) { double('out_1') }
    let(:out_2) { double('out_2') }
    let(:in_1_dup) { double('in_1_dup') }
    let(:in_2_dup) { double('in_2_dup') }
    let(:out_1_dup) { double('out_1_dup') }
    let(:out_2_dup) { double('out_2_dup') }
    before(:example) do
      allow(in_1).to receive(:dup).and_return(in_1_dup)
      allow(in_2).to receive(:dup).and_return(in_2_dup)
      allow(out_1).to receive(:dup).and_return(out_1_dup)
      allow(out_2).to receive(:dup).and_return(out_2_dup)
      allow(in_1).to receive(:==).with(in_1_dup).and_return(true)
      allow(in_2).to receive(:==).with(in_2_dup).and_return(true)
      allow(out_1).to receive(:==).with(out_1_dup).and_return(true)
      allow(out_2).to receive(:==).with(out_2_dup).and_return(true)
      allow(input).to receive(:morphword).and_return(nil)
      @word = Word.new(system)
      @word.input << in_1 << in_2
      @word.output << out_1 << out_2
      @word.add_to_io_corr(in_1, out_1)
      @word.add_to_io_corr(in_2, out_2)
      @word_dup = @word.dup
    end
    it 'the two are not the same object' do
      expect(@word_dup).not_to equal @word
    end
    it 'the two are equivalent' do
      expect(@word_dup).to eq @word
    end
    it 'has dup input element 0' do
      expect(@word_dup.input[0]).to equal in_1_dup
    end
    it 'has dup input element 1' do
      expect(@word_dup.input[1]).to equal in_2_dup
    end
    it 'has dup output element 0' do
      expect(@word_dup.output[0]).to equal out_1_dup
    end
    it 'has dup output element 1' do
      expect(@word_dup.output[1]).to equal out_2_dup
    end
    it 'has corresponding first elements' do
      expect(@word_dup.io_out_corr(in_1_dup)).to equal out_1_dup
    end
    it 'has corresponding second elements' do
      expect(@word_dup.io_out_corr(in_2_dup)).to equal out_2_dup
    end
  end

  context 'its dup_for_gen' do
    let(:in_1) { double('in_1') }
    let(:in_2) { double('in_2') }
    let(:in_3) { double('in_3') }
    let(:out_1) { double('out_1') }
    let(:out_2) { double('out_2') }
    before(:example) do
      allow(input).to receive(:morphword).and_return(nil)
      @word = Word.new(system)
      @word.input << in_1 << in_2 << in_3
      @word.output << out_1 << out_2
      @word.add_to_io_corr(in_1, out_1)
      @word.add_to_io_corr(in_2, out_2)
      @word_dup_gen = @word.dup_for_gen
    end
    it 'the two are not the same object' do
      expect(@word_dup_gen).not_to equal @word
    end
    it 'the two are equivalent' do
      expect(@word_dup_gen).to eq @word
    end
    it 'has the same input element 0' do
      expect(@word_dup_gen.input[0]).to equal in_1
    end
    it 'has the same input element 1' do
      expect(@word_dup_gen.input[1]).to equal in_2
    end
    it 'has no output correspondent for input element 3' do
      expect(@word_dup_gen.io_out_corr?(in_3)).to be false
    end
    it 'has the same output element 0' do
      expect(@word_dup_gen.output[0]).to equal out_1
    end
    it 'has the same output element 1' do
      expect(@word_dup_gen.output[1]).to equal out_2
    end
    it 'has corresponding first elements' do
      expect(@word_dup_gen.io_out_corr(in_1)).to equal out_1
      expect(@word_dup_gen.io_in_corr(out_1)).to equal in_1
    end
    it 'has corresponding second elements' do
      expect(@word_dup_gen.io_out_corr(in_2)).to equal out_2
    end
  end
end

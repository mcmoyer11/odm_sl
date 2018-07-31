# Author: Bruce Tesar

require 'word'

RSpec.describe Word, :wip do
  let(:system){double('system')}
  let(:candidate_class){double('candidate_class')}
  let(:candidate){double('candidate')}
  let(:input){double('input')}
  let(:output){double('output')}
  before(:example) do
    allow(candidate_class).to receive(:new).and_return(candidate)
    allow(system).to receive(:constraints)
    allow(candidate).to receive(:input).and_return(input)
    allow(candidate).to receive(:output).and_return(output)
  end

  context "given empty input and output" do
    before(:example) do
      @word = Word.new(system, input, output, candidate_class: candidate_class)
    end
    it "gives an empty IO correspondence" do
      expect(@word.io_corr).to be_empty
    end
    it "gives the input" do
      expect(@word.input).to eq input
    end
    it "gives the output" do
      expect(@word.output).to eq output
    end
  end
  
  context "with a single input segment with one set and one unset feature, #match_input_to_output" do
    let(:inseg1){double('inseg1')}
    let(:outseg1){double('outseg1')}
    let(:set_feat){double('set_feat')}
    let(:unset_feat){double('unset_feat')}
    let(:unset_feat_type){double('unset_feat_type')}
    let(:unset_feat_out){double('unset_feat_out')}
    let(:unset_feat_out_value){double('unset_feat_out_value')}
    let(:finst_1){double('finst_1')}
    let(:finst_2){double('finst_2')}
    before(:example) do
      allow(input).to receive(:<<).with(inseg1)
      allow(input).to receive(:each).and_yield(inseg1)
      allow(input).to receive(:each_feature).and_yield(finst_1).and_yield(finst_2)
      allow(input).to receive(:member?).with(inseg1).and_return(true)
      allow(finst_1).to receive(:element).and_return(inseg1)
      allow(finst_1).to receive(:feature).and_return(set_feat)
      allow(finst_2).to receive(:element).and_return(inseg1)
      allow(finst_2).to receive(:feature).and_return(unset_feat)
      allow(finst_2).to receive(:value=).with(unset_feat_out_value)
      allow(set_feat).to receive(:unset?).and_return(false)
      allow(unset_feat).to receive(:unset?).and_return(true)
      allow(unset_feat).to receive(:type).and_return(unset_feat_type)
      allow(unset_feat_out).to receive(:type).and_return(unset_feat_type)
      # required for internals of FeatureInstance
      allow(outseg1).to receive(:get_feature).with(unset_feat_type).and_return(unset_feat_out)
      allow(unset_feat_out).to receive(:value).and_return(unset_feat_out_value)      
      #
      @word = Word.new(system, input, output, candidate_class: candidate_class)
      allow(@word).to receive(:eval)
      @word.add_to_io_corr(inseg1,outseg1)
      @ret_value = @word.match_input_to_output!
    end
    it "assigns the unset feature the value of the output correspondent" do
      expect(finst_2).to have_received(:value=).with(unset_feat_out_value)
    end
    it "re-evaluates the constraint violations" do
      expect(@word).to have_received(:eval)
    end
    it "returns a reference to the word" do
      expect(@ret_value).to eq @word
    end
  end
  
  context "given two words with distinct but equivalent candidates" do
    let(:candidate2){double('candidate2')}
    let(:input2){double('input2')}
    let(:output2){double('output2')}
    before(:example) do
      allow(candidate_class).to receive(:new).and_return(candidate,candidate2)
      allow(candidate2).to receive(:input).and_return(input2)
      allow(candidate2).to receive(:output).and_return(output2)
      allow(candidate).to receive(:==).with(candidate2).and_return(true)
      @word1 = Word.new(system, input, output, candidate_class: candidate_class)
      @word2 = Word.new(system, input2, output2, candidate_class: candidate_class)
    end
    it "they are equivalent" do
      expect(@word1==@word2).to be true
    end
  end
  
  # Because Word#dup constructs a new Word internally, the testing will
  # involve some other dependent classes.
  context "its duplicate" do
    let(:in_1){double('in_1')}
    let(:in_2){double('in_2')}
    let(:out_1){double('out_1')}
    let(:out_2){double('out_2')}
    let(:in_1_dup){double('in_1_dup')}
    let(:in_2_dup){double('in_2_dup')}
    let(:out_1_dup){double('out_1_dup')}
    let(:out_2_dup){double('out_2_dup')}
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
    it "the two are not the same object" do
      expect(@word_dup).not_to equal @word
    end
    it "the two are equivalent" do
      expect(@word_dup).to eq @word
    end
    it "has dup input element 0" do
      expect(@word_dup.input[0]).to equal in_1_dup
    end
    it "has dup input element 1" do
      expect(@word_dup.input[1]).to equal in_2_dup
    end
    it "has dup output element 0" do
      expect(@word_dup.output[0]).to equal out_1_dup
    end
    it "has dup output element 1" do
      expect(@word_dup.output[1]).to equal out_2_dup
    end
    it "has corresponding first elements" do
      expect(@word_dup.io_corr.out_corr(in_1_dup)).to equal out_1_dup
    end
    it "has corresponding second elements" do
      expect(@word_dup.io_corr.out_corr(in_2_dup)).to equal out_2_dup
    end
  end
end # RSpec.describe Word

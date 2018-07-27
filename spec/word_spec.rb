# Author: Bruce Tesar

require 'word'

RSpec.describe Word, :wip do
  let(:system){double('system')}
  let(:candidate_class){double('candidate_class')}
  let(:candidate){double('candidate')}
  let(:input){[]}
  let(:output){[]}
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
    let(:set_feat_type){double('set_feat_type')}
    let(:set_feat_out){double('set_feat_out')}
    let(:set_feat_out_value){double('set_feat_out_value')}
    let(:unset_feat){double('unset_feat')}
    let(:unset_feat_type){double('unset_feat_type')}
    let(:unset_feat_out){double('unset_feat_out')}
    let(:unset_feat_out_value){double('unset_feat_out_value')}
    before(:example) do
      input << inseg1
      output << outseg1
      allow(inseg1).to receive(:each_feature).and_yield(set_feat).and_yield(unset_feat)
      allow(inseg1).to receive(:get_feature).with(set_feat_type).and_return(set_feat)
      allow(inseg1).to receive(:get_feature).with(unset_feat_type).and_return(unset_feat)
      allow(inseg1).to receive(:get_feature).with(set_feat_type).and_return(set_feat)
      allow(outseg1).to receive(:get_feature).with(set_feat_type).and_return(set_feat_out)
      allow(outseg1).to receive(:get_feature).with(unset_feat_type).and_return(unset_feat_out)
      allow(set_feat).to receive(:unset?).and_return(false)
      allow(set_feat).to receive(:value=).with(set_feat_out_value)
      allow(set_feat).to receive(:type).and_return(set_feat_type)
      allow(unset_feat).to receive(:unset?).and_return(true)
      allow(unset_feat).to receive(:value=).with(unset_feat_out_value)
      allow(unset_feat).to receive(:type).and_return(unset_feat_type)
      allow(set_feat_out).to receive(:type).and_return(set_feat_type)
      allow(set_feat_out).to receive(:value).and_return(set_feat_out_value)
      allow(unset_feat_out).to receive(:type).and_return(unset_feat_type)
      allow(unset_feat_out).to receive(:value).and_return(unset_feat_out_value)
      @word = Word.new(system, input, output, candidate_class: candidate_class)
      allow(@word).to receive(:eval)
      @word.io_corr << [inseg1,outseg1]
      @ret_value = @word.match_input_to_output!
    end
    it "assigns the unset feature the value of the output correspondent" do
      expect(unset_feat).to have_received(:value=).with(unset_feat_out_value)
    end
    it "does not change the set feature" do
      expect(set_feat).not_to have_received(:value=)
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
end # RSpec.describe Word

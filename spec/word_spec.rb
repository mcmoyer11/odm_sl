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

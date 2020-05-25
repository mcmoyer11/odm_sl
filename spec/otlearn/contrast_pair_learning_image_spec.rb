# Author: Bruce Tesar

require 'otlearn/contrast_pair_learning_image'
require 'sheet'

RSpec.describe OTLearn::ContrastPairLearningImage do
  let(:contrast_pair_learning){double('contrast_pair_learning')}
  let(:grammar_test_image_class){double('grammar_test_image_class')}
  let(:test_result){double('test_result')}
  let(:test_result_image){s=Sheet.new; s[1,1]="Test Result Image"; s}
  before(:each) do
    allow(contrast_pair_learning).to receive(:test_result).and_return(test_result)
    allow(grammar_test_image_class).to receive(:new).with(test_result).
      and_return(test_result_image)
  end

  context "given a successful contrast pair learning step" do
    let(:word1){double('word1')}
    let(:word2){double('word2')}
    let(:contrast_pair){[word1,word2]}
    before(:each) do
      allow(contrast_pair_learning).to receive(:changed?).and_return(true)
      allow(contrast_pair_learning).to receive(:contrast_pair).and_return(contrast_pair)
      allow(word1).to receive(:morphword).and_return("mw1")
      allow(word1).to receive(:input).and_return("in1")
      allow(word1).to receive(:output).and_return("out1")
      allow(word2).to receive(:morphword).and_return("mw2")
      allow(word2).to receive(:input).and_return("in2")
      allow(word2).to receive(:output).and_return("out2")
      @contrast_pair_learning_image =
        OTLearn::ContrastPairLearningImage.new(contrast_pair_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it "indicates the step type" do
      expect(@contrast_pair_learning_image[1,1]).to eq "Contrast Pair Learning"
    end
    it "indicates the contrast pair heading" do
      expect(@contrast_pair_learning_image[2,2]).to eq "Contrast Pair:"
    end
    it "indicates the first CP word" do
      expect(@contrast_pair_learning_image[2,3]).to eq "mw1 in1->out1"
    end
    it "indicates the second CP word" do
      expect(@contrast_pair_learning_image[2,4]).to eq "mw2 in2->out2"
    end
    it "constructs a grammar test image" do
      expect(grammar_test_image_class).to have_received(:new)
    end
    it "adds the test result image" do
      expect(@contrast_pair_learning_image[3,1]).to eq "Test Result Image"
    end
  end

  context "given an unsuccessful contrast pair learning step" do
    before(:each) do
      allow(contrast_pair_learning).to receive(:changed?).and_return(false)
      allow(contrast_pair_learning).to receive(:contrast_pair).and_return(nil)
      @contrast_pair_learning_image =
        OTLearn::ContrastPairLearningImage.new(contrast_pair_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it "indicates the step type" do
      expect(@contrast_pair_learning_image[1,1]).to eq "Contrast Pair Learning"
    end
    it "indicates that no contrast pair was found" do
      expect(@contrast_pair_learning_image[2,2]).to eq "None Found"
    end
    it "does not construct a grammar test image" do
      expect(grammar_test_image_class).not_to have_received(:new)
    end
    it "does not add a test result image" do
      expect(@contrast_pair_learning_image[3,1]).not_to eq "Test Result Image"
    end
  end
end # RSpec.describe ContrastPairLearningImage

# Author: Bruce Tesar

require 'otlearn/contrast_pair_learning_image'

RSpec.describe OTLearn::ContrastPairLearningImage, :wip do
  let(:contrast_pair_learning){double('contrast_pair_learning')}
  let(:grammar_test_image_class){double('grammar_test_image_class')}
  let(:test_result){double('test_result')}
  let(:test_result_image){s=Sheet.new; s[1,1]="Test Result Image"; s}
  before(:each) do
    allow(contrast_pair_learning).to receive(:test_result).and_return(test_result)
      allow(grammar_test_image_class).to receive(:new).with(test_result).
        and_return(test_result_image)
  end

  context "given a contrast pair learning step" do
    before(:each) do
      @contrast_pair_learning_image =
        OTLearn::ContrastPairLearningImage.new(contrast_pair_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it "indicates the step type" do
      expect(@contrast_pair_learning_image[1,1]).to eq "Contrast Pair Learning"
    end
    it "adds the test result image" do
      expect(@contrast_pair_learning_image[2,1]).to eq "Test Result Image"
    end
  end
end # RSpec.describe ContrastPairLearningImage

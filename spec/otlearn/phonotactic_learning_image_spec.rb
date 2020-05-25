# Author: Bruce Tesar

require 'otlearn/phonotactic_learning_image'

RSpec.describe OTLearn::PhonotacticLearningImage do
  let(:phonotactic_learning){double('phonotactic_learning')}
  let(:grammar_test_image_class){double('grammar_test_image_class')}
  let(:test_result){double('test_result')}
  let(:test_result_image){s=Sheet.new; s[1,1]="Test Result Image"; s}
  before(:each) do
    allow(phonotactic_learning).to receive(:test_result).and_return(test_result)
      allow(grammar_test_image_class).to receive(:new).with(test_result).
        and_return(test_result_image)
  end

  context "given a phonotactic learning step" do
    before(:each) do
      @phonotactic_learning_image =
        OTLearn::PhonotacticLearningImage.new(phonotactic_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it "indicates the step type" do
      expect(@phonotactic_learning_image[1,1]).to eq "Phonotactic Learning"
    end
    it "adds the test result image" do
      expect(@phonotactic_learning_image[2,1]).to eq "Test Result Image"
    end
  end
end # RSpec.describe PhonotacticLearningImage

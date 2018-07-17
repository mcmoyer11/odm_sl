# Author: Bruce Tesar

require 'otlearn/single_form_learning_image'

RSpec.describe OTLearn::SingleFormLearningImage do
  let(:single_form_learning){double('single_form_learning')}
  let(:grammar_test_image_class){double('grammar_test_image_class')}
  let(:test_result){double('test_result')}
  let(:test_result_image){s=Sheet.new; s[1,1]="Test Result Image"; s}
  before(:each) do
    allow(single_form_learning).to receive(:test_result).and_return(test_result)
      allow(grammar_test_image_class).to receive(:new).with(test_result).
        and_return(test_result_image)
  end

  context "given a single form learning step" do
    before(:each) do
      @single_form_learning_image =
        OTLearn::SingleFormLearningImage.new(single_form_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it "indicates the step type" do
      expect(@single_form_learning_image[1,1]).to eq "Single Form Learning"
    end
    it "adds the test result image" do
      expect(@single_form_learning_image[2,1]).to eq "Test Result Image"
    end
  end
end # RSpec.describe SingleFormLearningImage

# Author: Bruce Tesar

require 'otlearn/induction_learning_image'

RSpec.describe OTLearn::InductionLearningImage, :wip do
  let(:induction_learning){double('induction_learning')}
  let(:grammar_test_image_class){double('grammar_test_image_class')}
  let(:test_result){double('test_result')}
  let(:test_result_image){s=Sheet.new; s[1,1]="Test Result Image"; s}
  let(:step_type_string){"Induction Learning"}
  before(:each) do
      allow(induction_learning).to receive(:test_result).and_return(test_result)
      allow(grammar_test_image_class).to receive(:new).with(test_result).
        and_return(test_result_image)
  end
  
  context "given a step with fewest set features" do
    let(:step_subtype){OTLearn::InductionLearning::FEWEST_SET_FEATURES}
    let(:step_subtype_string){"Fewest Set Features"}
    before(:each) do
      allow(induction_learning).to receive(:step_subtype).and_return(step_subtype)
      @induction_learning_image = OTLearn::InductionLearningImage.new(induction_learning,
      grammar_test_image_class: grammar_test_image_class)
    end
    it "indicates the step type" do
      expect(@induction_learning_image[1,1]).to eq step_type_string
    end
    it "indicates the step subtype" do
      expect(@induction_learning_image[2,1]).to eq step_subtype_string
    end
    it "adds the test result image" do
      expect(@induction_learning_image[4,1]).to eq "Test Result Image"
    end
  end
end # RSpec.describe OTLearn::InductionLearningImage


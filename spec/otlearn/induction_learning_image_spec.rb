# Author: Bruce Tesar

require 'otlearn/induction_learning_image'

RSpec.describe OTLearn::InductionLearningImage, :wip do
  let(:induction_learning){double('induction_learning')}
  let(:fsf_image_class){double('fsf_image_class')}
  let(:fsf_image){s=Sheet.new; s[1,1]="FSF Image"; s}
  let(:grammar_test_image_class){double('grammar_test_image_class')}
  let(:test_result){double('test_result')}
  let(:test_result_image){s=Sheet.new; s[1,1]="Test Result Image"; s}
  let(:step_type_string){"Induction Learning"}
  before(:each) do
      allow(induction_learning).to receive(:test_result).and_return(test_result)
      allow(fsf_image_class).to receive(:new).and_return(fsf_image)
      allow(grammar_test_image_class).to receive(:new).with(test_result).
        and_return(test_result_image)
  end
  
  context "given a step with fewest set features" do
    let(:step_subtype){OTLearn::InductionLearning::FEWEST_SET_FEATURES}
    let(:step_subtype_string){"Fewest Set Features"}
    before(:each) do
      allow(induction_learning).to receive(:step_subtype).and_return(step_subtype)
      allow(induction_learning).to receive(:fsf_step)
      @induction_learning_image =
        OTLearn::InductionLearningImage.new(induction_learning,
        grammar_test_image_class: grammar_test_image_class,
        fsf_image_class: fsf_image_class)
    end
    it "indicates the step type" do
      expect(@induction_learning_image[1,1]).to eq step_type_string
    end
    it "adds the FSF image" do
      expect(@induction_learning_image[2,1]).to eq "FSF Image"
    end
    it "adds the test result image" do
      expect(@induction_learning_image[4,1]).to eq "Test Result Image"
    end
  end
end # RSpec.describe OTLearn::InductionLearningImage


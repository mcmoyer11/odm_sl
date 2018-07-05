# Author: Bruce Tesar

require_relative "../../lib/otlearn/language_learning_image"

RSpec.describe OTLearn::LanguageLearningImage, :wip do
  let(:language_learning){double('language_learning')}
  let(:grammar){double('grammar')}
  let(:grammar_label){double('grammar_label')}
  let(:grammar_test_image_class){double('grammar_test_image_class')}
  context "with one result" do
    let(:result1){double('result1')}
    let(:results_list){[result1]}
    let(:result_image1){s=Sheet.new; s[1,1]="result1"; s}
    before(:each) do
      allow(language_learning).to receive(:grammar).and_return(grammar)
      allow(grammar).to receive(:label).and_return(grammar_label)
      allow(language_learning).to receive(:learning_successful?).and_return(true)
      allow(language_learning).to receive(:results_list).and_return(results_list)
      allow(grammar_test_image_class).to \
        receive(:new).with(result1).and_return(result_image1)
      @ll_image =
        OTLearn::LanguageLearningImage.new(language_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it "adds the grammar label" do
      expect(@ll_image[1,1]).to eq grammar_label
    end
    it "indicates that learning succeeded" do
      expect(@ll_image[2,1]).to eq "Learned: true"
    end
    it "creates an image for the result" do
      expect(grammar_test_image_class).to have_received(:new).with(result1)
    end
    it "adds the result image" do
      expect(@ll_image[4,1]).to eq "result1"
    end
  end
  
  context "with two results" do
    let(:result1){double('result1')}
    let(:result2){double('result2')}
    let(:results_list){[result1,result2]}
    let(:result_image1){s=Sheet.new; s[1,1]="result1"; s}
    let(:result_image2){s=Sheet.new; s[1,1]="result2"; s}
    before(:each) do
      allow(language_learning).to receive(:grammar).and_return(grammar)
      allow(grammar).to receive(:label).and_return(grammar_label)
      allow(language_learning).to receive(:learning_successful?).and_return(true)
      allow(language_learning).to receive(:results_list).and_return(results_list)
      allow(grammar_test_image_class).to \
        receive(:new).and_return(result_image1,result_image2)
      @ll_image =
        OTLearn::LanguageLearningImage.new(language_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it "adds the grammar label" do
      expect(@ll_image[1,1]).to eq grammar_label
    end
    it "indicates that learning succeeded" do
      expect(@ll_image[2,1]).to eq "Learned: true"
    end
    it "creates an image for each result" do
      expect(grammar_test_image_class).to have_received(:new).exactly(2).times
    end
    it "adds the first result image" do
      expect(@ll_image[4,1]).to eq "result1"
    end
    it "adds the second result image" do
      expect(@ll_image[6,1]).to eq "result2"
    end
  end
 
end # RSpec.describe OTLearn::LanguageLearningImage


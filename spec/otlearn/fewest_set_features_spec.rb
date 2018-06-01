# Author: Bruce Tesar

require_relative '../../lib/otlearn/fewest_set_features'

RSpec.describe OTLearn::FewestSetFeatures do
  context "if #run is not called" do
    before(:each) do
      word_list = []
      grammar = double("grammar")
      prior_result = double("prior_result")
      language_learner = double("language_learner")
      @fewest_set_features = OTLearn::FewestSetFeatures.new(word_list, grammar, prior_result, language_learner)
    end
    
    it "returns an empty list of newly set features" do
      expect(@fewest_set_features.newly_set_features).to be_empty
    end
    
    it "indicates no change has occurred" do
      expect(@fewest_set_features.change?).to be false
    end
  end

end # RSpec.describe OTLearn::FewestSetFeatures


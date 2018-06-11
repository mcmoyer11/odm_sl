# Author: Morgan Moyer / Bruce Tesar

require_relative '../../lib/otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
  context "with no failed winners" do
    before(:each) do
      word_list = []
      grammar = double("grammar")
      prior_result = double("prior_result")
      language_learner = double("language_learner")
      allow(prior_result).to receive(:failed_winners).and_return([])
      @induction_learning = OTLearn::InductionLearning.new(word_list, grammar, prior_result, language_learner)
    end

    it "raises a RuntimeError" do
      expect{@induction_learning.run_induction_learning}.to raise_error(RuntimeError)
    end
  end
  
  context "with one inconsistent failed winner" do
    before(:each) do
      # set up the parameter doubles and create the test object
      word_list = []
      grammar = double("grammar")
      prior_result = double("prior_result")
      language_learner = double("language_learner")
      @failed_winner_1 = double("failed winner 1")
      allow(prior_result).to receive(:failed_winners).and_return([@failed_winner_1])
      @induction_learning = OTLearn::InductionLearning.new(word_list, grammar, prior_result, language_learner)
      # doubles relevant to checking failed winners for consistency
      mrcd_gram = double("mrcd grammar")
      allow(mrcd_gram).to receive(:consistent?).and_return(false)
      mrcd = double("mrcd")
      allow(mrcd).to receive(:grammar).and_return(mrcd_gram)
      allow(language_learner).to receive(:mismatch_consistency_check).with(grammar,[@failed_winner_1]).and_return(mrcd)
      # the test double for the FSF class, and the test fsf object to be returned
      @fsf = double("fsf")
      fsf_class = double("FSF_class")
      allow(fsf_class).to receive(:new).and_return(@fsf)
      @induction_learning.fewest_set_features_class = fsf_class
      allow(@fsf).to receive(:run)
      allow(@fsf).to receive(:change?)
    end
    
    it "does not raise an exception" do
      expect{@induction_learning.run_induction_learning}.not_to raise_error
    end
    
    it "calls fewest set features" do
      @induction_learning.run_induction_learning
      expect(@fsf).to have_received(:run)
    end
    
    context " that allows a feature to be set" do
      before(:each) do
        allow(@fsf).to receive(:change?).and_return(true)
      end
      it "reports that the grammar has changed" do
        @induction_learning.run_induction_learning
        expect(@induction_learning.change?).to be true
      end
    end

    context " that does not allow a feature to be set" do
      before(:each) do
        allow(@fsf).to receive(:change?).and_return(false)
      end
      it "reports that the grammar has not changed" do
        @induction_learning.run_induction_learning
        expect(@induction_learning.change?).to be false
      end
    end

  end

end # RSpec.describe OTLearn::InductionLearning
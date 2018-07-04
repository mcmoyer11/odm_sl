# Author: Morgan Moyer / Bruce Tesar

require_relative '../../lib/otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
  let(:word_list){[]}
  let(:grammar){double('grammar')}
  let(:prior_result){double('prior_result')}
  let(:language_learner){double('language_learner')}
  let(:fsf){double('fsf')}
  let(:fsf_class){double('FSF_class')}
  let(:otlearn_module){double('otlearn_module')}
  
  context "with no failed winners" do
    before(:each) do
      allow(prior_result).to receive(:failed_winners).and_return([])
    end
    it "raises a RuntimeError" do
      expect do
        OTLearn::InductionLearning.new(word_list, grammar, prior_result,
          language_learner)
      end.to raise_error(RuntimeError)
    end
  end
  
  context "with one inconsistent failed winner" do
    let(:failed_winner_1){double('failed_winner_1')}
    # doubles relevant to checking failed winners for consistency
    let(:mrcd_gram){double('mrcd_grammar')}
    let(:mrcd){double('mrcd')}
    before(:each) do
      allow(prior_result).to receive(:failed_winners).and_return([failed_winner_1])
      allow(mrcd_gram).to receive(:consistent?).and_return(false)
      allow(mrcd).to receive(:grammar).and_return(mrcd_gram)
      allow(fsf_class).to receive(:new).and_return(fsf)
      allow(otlearn_module).to receive(:mismatch_consistency_check).
          with(grammar,[failed_winner_1]).and_return(mrcd)
      allow(fsf).to receive(:run)
      allow(fsf).to receive(:change?)
    end
    
    context "that allows a feature to be set" do
      before(:each) do
        allow(fsf).to receive(:change?).and_return(true)
        @induction_learning = OTLearn::InductionLearning.new(word_list, grammar,
          prior_result, language_learner,
          learning_module: otlearn_module, fewest_set_features_class: fsf_class)
      end
      it "reports that the grammar has changed" do
        expect(@induction_learning).to be_changed
      end
      it "calls fewest set features" do
        expect(fsf_class).to have_received(:new)
      end
    end

    context " that does not allow a feature to be set" do
      before(:each) do
        allow(fsf).to receive(:change?).and_return(false)
        @induction_learning = OTLearn::InductionLearning.new(word_list, grammar,
          prior_result, language_learner,
          learning_module: otlearn_module, fewest_set_features_class: fsf_class)
      end
      it "reports that the grammar has not changed" do
        expect(@induction_learning).not_to be_changed
      end
      it "calls fewest set features" do
        expect(fsf_class).to have_received(:new)
      end
    end
  end

end # RSpec.describe OTLearn::InductionLearning

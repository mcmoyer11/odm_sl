# Author: Bruce Tesar

require_relative '../../lib/otlearn/single_form_learning'

RSpec.describe OTLearn::SingleFormLearning, :wip do
  let(:win1){double('winner 1')}
  let(:grammar){double('grammar')}
  let(:tester_class){double('tester class')}
  let(:tester_obj){instance_double(OTLearn::GrammarTest)}
  let(:otlearn_module){double('OTLearn module')}
  let(:consistency_result){double('consistency_result')}
  let(:cr_grammar){double('cr_grammar')}
  
  context "with one correct winner" do    
    before(:each) do
      @winners = [win1]
      allow(tester_class).to receive(:new).with([win1], grammar).and_return(tester_obj)
      allow(tester_obj).to receive(:all_correct?).and_return(true)
      allow(otlearn_module).to receive(:mismatch_consistency_check)
      #
      @single_form_learning = OTLearn::SingleFormLearning.new(@winners, grammar)
      @single_form_learning.tester_class = tester_class
      @single_form_learning.otlearn_module = otlearn_module
      @run_return_value = @single_form_learning.run
    end
    it "does not change the grammar" do
      expect(@single_form_learning).not_to be_changed
    end
    it "#run returns a value of false" do
      expect(@run_return_value).to be false
    end
    it "returns a winner list with one winner" do
      expect(@single_form_learning.winner_list).to eq @winners
    end
    it "returns the grammar unchanged" do
      expect(@single_form_learning.grammar).to eq grammar
    end
    it "tests the winner" do
      expect(tester_class).to have_received(:new).with([win1], grammar)
    end    
    it "does not perform a mismatch consistency check" do
      expect(otlearn_module).not_to have_received(:mismatch_consistency_check)
    end  
  end
  
  context "with one incorrect winner with a settable feature and other unsettable features" do
    before(:each) do
      @winners = [win1]
      allow(tester_class).to receive(:new).with([win1], grammar).and_return(tester_obj)
      allow(tester_obj).to receive(:all_correct?).and_return(false)
      allow(consistency_result).to receive(:grammar).and_return(cr_grammar)
      allow(otlearn_module).to receive(:mismatch_consistency_check).and_return(consistency_result)
      allow(otlearn_module).to receive(:set_uf_values).with([win1], grammar).and_return(["feature1"],[])
      allow(otlearn_module).to receive(:new_rank_info_from_feature).with(grammar,@winners,"feature1")
      allow(otlearn_module).to receive(:ranking_learning_faith_low).and_return(false)
      allow(cr_grammar).to receive(:consistent?).and_return(false, false)
      #
      @single_form_learning = OTLearn::SingleFormLearning.new(@winners, grammar)
      @single_form_learning.tester_class = tester_class
      @single_form_learning.otlearn_module = otlearn_module
      @run_return_value = @single_form_learning.run
    end
    it "changes the grammar" do
      expect(@single_form_learning).to be_changed
    end
    it "#run returns a value of true" do
      expect(@run_return_value).to be true
    end
    it "returns a winner list with one winner" do
      expect(@single_form_learning.winner_list).to eq @winners
    end
    it "returns the grammar" do
      expect(@single_form_learning.grammar).to eq grammar
    end
    it "tests the winner twice" do
      expect(tester_class).to have_received(:new).with([win1], grammar).exactly(2).times
    end    
    it "performs two mismatch consistency checks" do
      expect(otlearn_module).to have_received(:mismatch_consistency_check).with(grammar,[win1]).exactly(2).times
    end
    it "calls set_uf_features twice" do
      expect(otlearn_module).to have_received(:set_uf_values).with([win1],grammar).exactly(2).times
    end
    it "checks for new ranking information on the set feature once" do
      expect(otlearn_module).to have_received(:new_rank_info_from_feature).with(grammar,@winners,"feature1").exactly(1).times
    end
  end
  
end # RSpec.describe OTLearn::SingleFormLearning

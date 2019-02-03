# Author: Bruce Tesar

require_relative '../../lib/otlearn/phonotactic_learning'
require_relative '../../lib/otlearn/language_learning'

RSpec.describe OTLearn::PhonotacticLearning do
  let(:winner_list){double('winner_list')}
  let(:output_list){double('output_list')}
  let(:grammar){double('grammar')}
  let(:otlearn_module){double('otlearn_module')}
  let(:mrcd_result){double('mrcd_result')}
  let(:grammar_test_class){double('grammar_test_class')}
  let(:grammar_test){double('grammar_test')}
  let(:loser_selector){double('loser_selector')}
  context "with a winner list and a grammar, sufficient to learn all the words" do
    before(:each) do
      allow(output_list).to receive(:map).and_return(winner_list)
      # winner_list.each() takes a block which assigns output-matching values
      # to unset features.
      allow(winner_list).to receive(:each)
      allow(otlearn_module).to receive(:ranking_learning).
        and_return(mrcd_result)
      allow(mrcd_result).to receive(:any_change?).and_return(true)
      allow(grammar_test_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
      @phonotactic_learning =
        OTLearn::PhonotacticLearning.new(output_list, grammar,
        learning_module: otlearn_module, grammar_test_class: grammar_test_class,
        loser_selector: loser_selector)
    end
    it "calls ranking learning" do
      expect(otlearn_module).to have_received(:ranking_learning).
        with(winner_list,grammar,loser_selector)
    end
    it "indicates if learning made any changes to the grammar" do
      expect(@phonotactic_learning).to be_changed
    end
    it "gives the grammar test result" do
      expect(@phonotactic_learning.test_result).to eq grammar_test
    end
    it "indicates that all words are handled correctly" do
      expect(@phonotactic_learning).to be_all_correct
    end
    it "has step type PHONOTACTIC" do
      expect(@phonotactic_learning.step_type).to \
        eq OTLearn::LanguageLearning::PHONOTACTIC
    end
  end
  
  context "with a winner list causing no change, not all words learned" do
    before(:each) do
      allow(output_list).to receive(:map).and_return(winner_list)
      # winner_list.each() takes a block which assigns output-matching values
      # to unset features.
      allow(winner_list).to receive(:each)
      allow(otlearn_module).to receive(:ranking_learning).
        and_return(mrcd_result)
      allow(mrcd_result).to receive(:any_change?).and_return(false)
      allow(grammar_test_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      @phonotactic_learning =
        OTLearn::PhonotacticLearning.new(output_list, grammar,
        learning_module: otlearn_module, grammar_test_class: grammar_test_class,
        loser_selector: loser_selector)
    end
    it "calls ranking learning" do
      expect(otlearn_module).to have_received(:ranking_learning).
        with(winner_list,grammar,loser_selector)
    end
    it "indicates if learning made any changes to the grammar" do
      expect(@phonotactic_learning).not_to be_changed
    end
    it "gives the grammar test result" do
      expect(@phonotactic_learning.test_result).to eq grammar_test
    end
    it "indicates that not all words are handled correctly" do
      expect(@phonotactic_learning).not_to be_all_correct
    end
    it "has step type PHONOTACTIC" do
      expect(@phonotactic_learning.step_type).to \
        eq OTLearn::LanguageLearning::PHONOTACTIC
    end    
  end
end # RSpec.describe OTLearn::PhonotacticLearning

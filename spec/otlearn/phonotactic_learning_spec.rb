# Author: Bruce Tesar

require 'otlearn/phonotactic_learning'
require 'otlearn/language_learning'

RSpec.describe OTLearn::PhonotacticLearning, :wip do
  context "with a winner list and a grammar, sufficient to learn all the words" do
    let(:winner_list){double('winner_list')}
    let(:output_list){double('output_list')}
    let(:grammar){double('grammar')}
    let(:otlearn_module){double('otlearn_module')}
    let(:grammar_test_class){double('grammar_test_class')}
    let(:grammar_test){double('grammar_test')}
    let(:loser_selector){double('loser_selector')}
    before(:each) do
      allow(output_list).to receive(:map).and_return(winner_list)
      # winner_list.each() takes a block which assigns output-matching values
      # to unset features.
      allow(winner_list).to receive(:each)
      allow(otlearn_module).to receive(:ranking_learning).
        and_return(true)
      allow(grammar_test_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
      @phonotactic_learning =
        OTLearn::PhonotacticLearning.new(output_list, grammar,
        learning_module: otlearn_module, grammar_test_class: grammar_test_class,
        loser_selector: loser_selector)
    end
    it "assigns output-matching values to unset features" do
      expect(winner_list).to have_received(:each)
    end
    it "calls ranking learning" do
      expect(otlearn_module).to have_received(:ranking_learning).
        with(winner_list,grammar,loser_selector)
    end
    it "indicates if learning made any changes to the grammar" do
      expect(@phonotactic_learning).to be_changed
    end
    it "runs a grammar test after learning" do
      expect(grammar_test_class).to have_received(:new)
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
end # RSpec.describe OTLearn::PhonotacticLearning

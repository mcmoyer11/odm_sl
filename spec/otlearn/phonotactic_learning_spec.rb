# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/phonotactic_learning'
require 'otlearn/language_learning'

RSpec.describe OTLearn::PhonotacticLearning do
  let(:winner_list) { double('winner_list') }
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:mrcd_result) { double('mrcd_result') }
  let(:gtest_class) { double('gtest_class') }
  let(:grammar_test) { double('grammar_test') }
  let(:erc_learner) { double('erc_learner') }
  context 'with a phonotactically learnable winner list and a grammar' do
    before(:example) do
      allow(output_list).to receive(:map).and_return(winner_list)
      # winner_list.each() takes a block which assigns output-matching values
      # to unset features.
      allow(winner_list).to receive(:each)
      allow(erc_learner).to receive(:run).and_return(mrcd_result)
      allow(mrcd_result).to receive(:any_change?).and_return(true)
      allow(gtest_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
      phonotactic_learning =
        OTLearn::PhonotacticLearning.new(gtest_class: gtest_class)
      phonotactic_learning.erc_learner = erc_learner
      @step = phonotactic_learning.run(output_list, grammar)
    end
    it 'calls the ERC learner' do
      expect(erc_learner).to have_received(:run).with(winner_list, grammar)
    end
    it 'indicates if learning made any changes to the grammar' do
      expect(@step).to be_changed
    end
    it 'gives the grammar test result' do
      expect(@step.test_result).to eq grammar_test
    end
    it 'indicates that all words are handled correctly' do
      expect(@step).to be_all_correct
    end
    it 'has step type PHONOTACTIC' do
      expect(@step.step_type).to eq OTLearn::PHONOTACTIC
    end
  end

  context 'with a winner list causing no change, not all words learned' do
    before(:example) do
      allow(output_list).to receive(:map).and_return(winner_list)
      # winner_list.each() takes a block which assigns output-matching values
      # to unset features.
      allow(winner_list).to receive(:each)
      allow(erc_learner).to receive(:run).and_return(mrcd_result)
      allow(mrcd_result).to receive(:any_change?).and_return(false)
      allow(gtest_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      phonotactic_learning =
        OTLearn::PhonotacticLearning.new(gtest_class: gtest_class)
      phonotactic_learning.erc_learner = erc_learner
      @step = phonotactic_learning.run(output_list, grammar)
    end
    it 'calls the ERC learner' do
      expect(erc_learner).to have_received(:run).with(winner_list, grammar)
    end
    it 'indicates if learning made any changes to the grammar' do
      expect(@step).not_to be_changed
    end
    it 'gives the grammar test result' do
      expect(@step.test_result).to eq grammar_test
    end
    it 'indicates that not all words are handled correctly' do
      expect(@step).not_to be_all_correct
    end
    it 'has step type PHONOTACTIC' do
      expect(@step.step_type).to eq OTLearn::PHONOTACTIC
    end
  end
end

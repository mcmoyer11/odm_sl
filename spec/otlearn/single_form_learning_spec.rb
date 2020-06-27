# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/single_form_learning'
require 'otlearn/language_learning'
require 'otlearn/grammar_test'

RSpec.describe OTLearn::SingleFormLearning do
  let(:win1) { double('winner 1') }
  let(:out1) { double('output 1') }
  let(:grammar) { double('grammar') }
  let(:gtest_class) { double('gtest_class') }
  let(:grammar_test) { instance_double(OTLearn::GrammarTest) }
  let(:otlearn_module) { double('OTLearn module') }
  let(:loser_selector) { double('loser_selector') }
  let(:mrcd_result) { double('mrcd_result') }
  before(:example) do
    allow(win1).to receive(:match_input_to_output!)
  end

  context 'with one correct winner' do
    let(:winner_list) { [win1] }
    let(:output_list) { [out1] }
    before(:example) do
      allow(output_list).to receive(:map).and_return(winner_list)
      allow(grammar).to receive(:parse_output).with(out1).and_return(win1)
      allow(otlearn_module).to\
        receive(:set_uf_values).with([win1], grammar).and_return([])
      allow(gtest_class).to\
        receive(:new).with([out1], grammar).and_return(grammar_test)
      allow(gtest_class).to\
        receive(:new).with(output_list, grammar).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
      @single_form_learning =
        OTLearn::SingleFormLearning.new(learning_module: otlearn_module,
        gtest_class: gtest_class,
        loser_selector: loser_selector)
      @sf_step = @single_form_learning.run(output_list, grammar)
    end
    it 'does not change the grammar' do
      expect(@sf_step).not_to be_changed
    end
    it 'calls set_uf_features once' do
      expect(otlearn_module).to\
        have_received(:set_uf_values).with([win1], grammar).exactly(1).time
    end
    it 'tests the winner once at the end of the step' do
      expect(gtest_class).to have_received(:new).exactly(1).time
    end
    it 'gives the grammar test result' do
      expect(@sf_step.test_result).to eq grammar_test
    end
    it 'indicates that all words are handled correctly' do
      expect(@sf_step.all_correct?).to be true
    end
    it 'has step type SINGLE_FORM' do
      expect(@sf_step.step_type).to \
        eq OTLearn::SINGLE_FORM
    end
  end

  context 'with one incorrect winner with a settable feature and other unsettable features' do
    let(:winner_list) { [win1] }
    let(:output_list) { [out1] }
    before(:example) do
      allow(output_list).to receive(:map).and_return(winner_list)
      allow(grammar).to receive(:parse_output).with(out1).and_return(win1)
      allow(otlearn_module).to\
        receive(:set_uf_values).with([win1], grammar)\
                               .and_return(['feature1'], [])
      allow(otlearn_module).to\
        receive(:new_rank_info_from_feature).with(grammar, winner_list, 'feature1', loser_selector: loser_selector)
      allow(otlearn_module).to\
        receive(:ranking_learning).and_return(mrcd_result)
      allow(mrcd_result).to receive(:any_change?).and_return(false)
      allow(gtest_class).to receive(:new).and_return(grammar_test)
      allow(gtest_class).to\
        receive(:new).with([out1], grammar).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      @single_form_learning =
        OTLearn::SingleFormLearning.new(learning_module: otlearn_module,
        gtest_class: gtest_class,
        loser_selector: loser_selector)
      @sf_step = @single_form_learning.run(output_list, grammar)
    end
    it 'changes the grammar' do
      expect(@sf_step).to be_changed
    end
    it 'calls set_uf_features twice' do
      expect(otlearn_module).to\
        have_received(:set_uf_values).with([win1], grammar).exactly(2).times
    end
    it 'checks for new ranking information on the set feature once' do
      expect(otlearn_module).to\
        have_received(:new_rank_info_from_feature).with(grammar, winner_list, 'feature1', loser_selector:loser_selector).exactly(1).times
    end
    it 'tests the winner once at the end' do
      expect(gtest_class).to have_received(:new).exactly(1).time
    end
    it 'gives the grammar test result' do
      expect(@sf_step.test_result).to eq grammar_test
    end
    it 'indicates that not all words are handled correctly' do
      expect(@sf_step.all_correct?).to be false
    end
  end
end

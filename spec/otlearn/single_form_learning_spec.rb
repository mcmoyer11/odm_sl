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
  let(:para_erc_learner) { double('para_erc_learner') }
  let(:otlearn_module) { double('OTLearn module') }
  before(:example) do
    allow(win1).to receive(:match_input_to_output!)
  end

  context 'with one correct winner' do
    let(:winner_list) { [win1] }
    let(:output_list) { [out1] }
    before(:example) do
      allow(grammar).to receive(:parse_output).with(out1).and_return(win1)
      allow(otlearn_module).to receive(:set_uf_values).and_return([])
      allow(gtest_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
      single_form_learning =
        OTLearn::SingleFormLearning.new(learning_module: otlearn_module,
                                        gtest_class: gtest_class)
      single_form_learning.para_erc_learner = para_erc_learner
      @sf_step = single_form_learning.run(output_list, grammar)
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
      allow(grammar).to receive(:parse_output).with(out1).and_return(win1)
      allow(otlearn_module).to\
        receive(:set_uf_values).and_return(['feature1'], [])
      allow(para_erc_learner).to receive(:run)
      allow(gtest_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      single_form_learning =
        OTLearn::SingleFormLearning.new(learning_module: otlearn_module,
                                        gtest_class: gtest_class)
      single_form_learning.para_erc_learner = para_erc_learner
      @sf_step = single_form_learning.run(output_list, grammar)
    end
    it 'changes the grammar' do
      expect(@sf_step).to be_changed
    end
    it 'calls set_uf_features twice' do
      expect(otlearn_module).to\
        have_received(:set_uf_values).with([win1], grammar).exactly(2).times
    end
    it 'checks for new ranking information on the set feature once' do
      expect(para_erc_learner).to\
        have_received(:run).with('feature1', grammar, output_list)\
                           .exactly(1).times
    end
    it 'tests the winner once at the end' do
      expect(gtest_class).to\
        have_received(:new).with(output_list, grammar).exactly(1).time
    end
    it 'gives the grammar test result' do
      expect(@sf_step.test_result).to eq grammar_test
    end
    it 'indicates that not all words are handled correctly' do
      expect(@sf_step.all_correct?).to be false
    end
  end
end

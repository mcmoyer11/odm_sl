# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/contrast_pair_learning'

RSpec.describe OTLearn::ContrastPairLearning do
  let(:winner_list) { double('winner_list') }
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:prior_result) { double('prior_result') }
  let(:otlearn_module) { double('OTLearn module') }
  let(:first_cp) { double('first_cp') }
  let(:second_cp) { double('second_cp') }
  let(:grammar_tester) { double('grammar_tester') }
  let(:test_result) { double('test_result') }
  let(:para_erc_learner) { double('para_erc_learner') }
  let(:feature_learner) { double('feature_learner') }
  before(:each) do
    allow(grammar).to receive(:system)
    allow(output_list).to receive(:map).and_return(winner_list)
    allow(para_erc_learner).to receive(:run)
  end

  context 'with first pair informative' do
    before(:each) do
      # The block defines the internal behavior of the test double.
      # The method needs to call #yield on the parameter +result+ passed in
      # by Enumerator.new().
      allow(otlearn_module).to receive(:generate_contrast_pair) do
        |result, win_list, grammar, p_result|
        result.yield first_cp
      end
      # allow(otlearn_module).to\
      #   receive(:set_uf_values).with(first_cp, grammar).and_return(['feat1'])
      allow(feature_learner).to\
        receive(:run).with(first_cp, grammar).and_return(['feat1'])
      allow(grammar_tester).to\
        receive(:run).and_return(prior_result, test_result)
      allow(test_result).to receive(:all_correct?).and_return(false)
      cp_learner = OTLearn::ContrastPairLearning\
                   .new(learning_module: otlearn_module)
      cp_learner.para_erc_learner = para_erc_learner
      cp_learner.feature_learner = feature_learner
      cp_learner.grammar_tester = grammar_tester
      @cp_step = cp_learner.run(output_list, grammar)
    end
    it 'returns the first pair' do
      expect(@cp_step.contrast_pair).to eq first_cp
    end
    it 'checks for ranking information wih feat1' do
      expect(para_erc_learner).to have_received(:run)\
        .with('feat1', grammar, output_list).exactly(1).times
    end
    it 'changes the grammar' do
      expect(@cp_step).to be_changed
    end
    it 'runs a grammar test before and after learning' do
      expect(grammar_tester).to have_received(:run).exactly(2).times
    end
    it 'gives the grammar test result' do
      expect(@cp_step.test_result).to eq test_result
    end
    it 'indicates that not all words are handled correctly' do
      expect(@cp_step).not_to be_all_correct
    end
    it 'has step type CONTRAST_PAIR' do
      expect(@cp_step.step_type).to eq OTLearn::CONTRAST_PAIR
    end
  end

  context 'with one uniformative pair' do
    before(:each) do
      # The block defines the internal behavior of the test double.
      # The method needs to call #yield on the parameter +result+ passed in
      # by Enumerator.new().
      allow(otlearn_module).to receive(:generate_contrast_pair) do
        |result, win_list, grammar, p_result|
        result.yield first_cp
      end
      # allow(otlearn_module).to\
      #   receive(:set_uf_values).with(first_cp, grammar).and_return([])
      allow(feature_learner).to\
        receive(:run).with(first_cp, grammar).and_return([])
      allow(grammar_tester).to\
        receive(:run).and_return(prior_result, test_result)
      allow(test_result).to receive(:all_correct?).and_return(false)
      cp_learner = OTLearn::ContrastPairLearning\
                   .new(learning_module: otlearn_module)
      cp_learner.para_erc_learner = para_erc_learner
      cp_learner.feature_learner = feature_learner
      cp_learner.grammar_tester = grammar_tester
      @cp_step = cp_learner.run(output_list, grammar)
    end
    it 'returns no contrast pair' do
      expect(@cp_step.contrast_pair).to be_nil
    end
    it 'does not check for ranking information' do
      expect(para_erc_learner).not_to have_received(:run)
    end
    it 'does not change the grammar' do
      expect(@cp_step).not_to be_changed
    end
    it 'runs a grammar test before and after learning' do
      expect(grammar_tester).to have_received(:run).exactly(2).times
    end
    it 'gives the grammar test result' do
      expect(@cp_step.test_result).to eq test_result
    end
    it 'indicates that not all words are handled correctly' do
      expect(@cp_step).not_to be_all_correct
    end
  end

  context 'with the second pair informative' do
    before(:each) do
      # The block defines the internal behavior of the test double.
      # The method needs to call #yield on the parameter +result+ passed in
      # by Enumerator.new().
      allow(otlearn_module).to receive(:generate_contrast_pair) do
        |result, win_list, grammar, p_result|
        result.yield first_cp
      end
      allow(otlearn_module).to receive(:generate_contrast_pair) do
        |result, win_list, grammar, p_result|
        result.yield second_cp
      end
      allow(otlearn_module).to\
        receive(:set_uf_values).with(first_cp, grammar).and_return([])
      # allow(otlearn_module).to\
      #   receive(:set_uf_values).with(second_cp, grammar)\
      #                          .and_return(['feat1'])
      allow(feature_learner).to\
        receive(:run).with(second_cp, grammar).and_return(['feat1'])
      allow(grammar_tester).to\
        receive(:run).and_return(prior_result, test_result)
      allow(test_result).to receive(:all_correct?).and_return(false)
      cp_learner = OTLearn::ContrastPairLearning\
                   .new(learning_module: otlearn_module)
      cp_learner.para_erc_learner = para_erc_learner
      cp_learner.feature_learner = feature_learner
      cp_learner.grammar_tester = grammar_tester
      @cp_step = cp_learner.run(output_list, grammar)
    end
    it 'returns the second pair' do
      expect(@cp_step.contrast_pair).to eq second_cp
    end
    it 'checks for ranking information wih feat1' do
      expect(para_erc_learner).to have_received(:run)\
        .with('feat1', grammar, output_list).exactly(1).times
    end
    it 'changes the grammar' do
      expect(@cp_step).to be_changed
    end
    it 'runs a grammar test before and after learning' do
      expect(grammar_tester).to have_received(:run).exactly(2).times
    end
    it 'gives the grammar test result' do
      expect(@cp_step.test_result).to eq test_result
    end
    it 'indicates that not all words are handled correctly' do
      expect(@cp_step).not_to be_all_correct
    end
  end
end

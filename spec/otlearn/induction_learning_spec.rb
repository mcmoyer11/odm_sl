# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
  let(:winner_list) { double('winner_list') }
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:prior_result) { double('prior_result') }
  let(:fsf) { double('fsf') }
  let(:fsf_class) { double('FSF_class') }
  let(:mmr_class) { double('MMR_class') }
  let(:mmr) { double('mmr') }
  let(:otlearn_module) { double('otlearn_module') }
  let(:grammar_test_class) { double('grammar_test_class') }
  let(:grammar_test) { double('grammar_test') }
  before(:each) do
    allow(grammar).to receive(:system)
    allow(output_list).to receive(:map).and_return(winner_list)
  end

  context 'with no failed winners' do
    before(:each) do
      allow(grammar_test_class).to receive(:new).and_return(prior_result, grammar_test)
      allow(prior_result).to receive(:failed_winners).and_return([])
    end
    it 'raises a RuntimeError' do
      expect do
        @in_learner = OTLearn::InductionLearning\
                        .new(grammar_test_class: grammar_test_class)
        @in_learner.run(output_list, grammar)
      end.to raise_error(RuntimeError)
    end
    it 'defines a substep constant for fewest set features' do
      expect(defined?(OTLearn::InductionLearning::FEWEST_SET_FEATURES)).to be_truthy
    end
    it 'defines a substep constant for max mismatch ranking' do
      expect(defined?(OTLearn::InductionLearning::FEWEST_SET_FEATURES)).to be_truthy
    end
  end

  context 'with one inconsistent failed winner' do
    let(:failed_winner_1) { double('failed_winner_1') }
    # doubles relevant to checking failed winners for consistency
    let(:mrcd_gram) { double('mrcd_grammar') }
    let(:mrcd) { double('mrcd') }
    before(:each) do
      allow(prior_result).to receive(:failed_winners).and_return([failed_winner_1])
      allow(mrcd_gram).to receive(:consistent?).and_return(false)
      allow(mrcd).to receive(:grammar).and_return(mrcd_gram)
      allow(fsf_class).to receive(:new).and_return(fsf)
      allow(fsf).to receive(:changed?)
      allow(otlearn_module).to receive(:mismatch_consistency_check).
          with(grammar, [failed_winner_1]).and_return(mrcd)
      allow(grammar_test_class).to receive(:new).and_return(prior_result, grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
    end

    context 'that allows a feature to be set' do
      before(:each) do
        allow(fsf).to receive(:changed?).and_return(true)
        @in_learner =
          OTLearn::InductionLearning.new(learning_module: otlearn_module,
          grammar_test_class: grammar_test_class,
          fewest_set_features_class: fsf_class)
        @in_learner.run(output_list, grammar)
      end
      it 'reports that the grammar has changed' do
        expect(@in_learner).to be_changed
      end
      it 'calls fewest set features' do
        expect(fsf_class).to have_received(:new)
      end
      it 'gives the fsf step object' do
        expect(@in_learner.fsf_step).to eq fsf
      end
      it 'runs a grammar test after learning' do
        expect(grammar_test_class).to have_received(:new).exactly(2).times
      end
      it 'gives the grammar test result' do
        expect(@in_learner.test_result).to eq grammar_test
      end
      it 'indicates that all words are handled correctly' do
        expect(@in_learner).to be_all_correct
      end
      it 'has step type INDUCTION' do
        expect(@in_learner.step_type).to \
          eq OTLearn::INDUCTION
      end
      it 'has step subtype FEWEST_SET_FEATURES' do
        expect(@in_learner.step_subtype).to \
          eq OTLearn::InductionLearning::FEWEST_SET_FEATURES
      end
    end

    context ' that does not allow a feature to be set' do
      before(:each) do
        allow(fsf).to receive(:changed?).and_return(false)
        @in_learner =
          OTLearn::InductionLearning.new(learning_module: otlearn_module,
          grammar_test_class: grammar_test_class,
          fewest_set_features_class: fsf_class)
        @in_learner.run(output_list, grammar)
      end
      it 'reports that the grammar has not changed' do
        expect(@in_learner).not_to be_changed
      end
      it 'calls fewest set features' do
        expect(fsf_class).to have_received(:new)
      end
      it 'gives the fsf step object' do
        expect(@in_learner.fsf_step).to eq fsf
      end
      it 'runs a grammar test after learning' do
        expect(grammar_test_class).to have_received(:new).exactly(2).times
      end
      it 'gives the grammar test result' do
        expect(@in_learner.test_result).to eq grammar_test
      end
      it 'indicates that all words are handled correctly' do
        expect(@in_learner).to be_all_correct
      end
    end
  end

  context 'with one consistent failed winner' do
    let(:failed_winner_1) { double('failed_winner_1') }
    let(:failed_output_1) { double('failed_output_1') }
    # doubles relevant to checking failed winners for consistency
    let(:mrcd_gram) { double('mrcd_grammar') }
    let(:mrcd) { double('mrcd') }
    before(:each) do
      allow(prior_result).to receive(:failed_winners).and_return([failed_winner_1])
      allow(failed_winner_1).to receive(:output).and_return(failed_output_1)
      allow(mrcd_gram).to receive(:consistent?).and_return(true)
      allow(mrcd).to receive(:grammar).and_return(mrcd_gram)
      allow(mmr_class).to\
        receive(:new).with([failed_output_1], grammar).and_return(mmr)
      allow(mmr).to receive(:changed?)
      allow(otlearn_module).to receive(:mismatch_consistency_check).
          with(grammar, [failed_winner_1]).and_return(mrcd)
      allow(grammar_test_class).to receive(:new).
        and_return(prior_result, grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
    end

    context 'that allows new ranking information' do
      before(:each) do
        allow(mmr).to receive(:changed?).and_return(true)
        @in_learner =
          OTLearn::InductionLearning.new(learning_module: otlearn_module,
          grammar_test_class: grammar_test_class,
          fewest_set_features_class: fsf_class,
          max_mismatch_ranking_class: mmr_class)
        @in_learner.run(output_list, grammar)
      end
      it 'reports that the grammar has changed' do
        expect(@in_learner).to be_changed
      end
      it 'calls max mismatch ranking' do
        expect(mmr_class).to have_received(:new)
      end
      it 'gives the mmr step object' do
        expect(@in_learner.mmr_step).to eq mmr
      end
      it 'runs a grammar test after learning' do
        expect(grammar_test_class).to have_received(:new).exactly(2).times
      end
      it 'gives the grammar test result' do
        expect(@in_learner.test_result).to eq grammar_test
      end
      it 'indicates that all words are handled correctly' do
        expect(@in_learner).to be_all_correct
      end
      it 'has step type INDUCTION' do
        expect(@in_learner.step_type).to \
          eq OTLearn::INDUCTION
      end
      it 'has step subtype MAX_MISMATCH_RANKING' do
        expect(@in_learner.step_subtype).to \
          eq OTLearn::InductionLearning::MAX_MISMATCH_RANKING
      end
    end
  end
end

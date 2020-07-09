# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:prior_result) { double('prior_result') }
  let(:fsf) { double('fsf') }
  let(:fsf_substep) { double('fsf_substep') }
  let(:mmr) { double('mmr') }
  let(:mmr_substep) { double('mmr_substep') }
  let(:consistency_checker) { double('consistency_checker') }
  let(:grammar_tester) { double('grammar_tester') }
  let(:test_result) { double('test_result') }
  before(:each) do
    allow(grammar).to receive(:system)
    allow(fsf).to receive(:run).and_return(fsf_substep)
    allow(fsf_substep).to receive(:changed?)
    allow(fsf_substep).to\
      receive(:subtype).and_return(OTLearn::FEWEST_SET_FEATURES)
    allow(mmr).to receive(:run).and_return(mmr_substep)
    allow(mmr_substep).to receive(:changed?)
    allow(mmr_substep).to\
      receive(:subtype).and_return(OTLearn::MAX_MISMATCH_RANKING)
  end

  context 'with no failed winners' do
    before(:each) do
      allow(grammar_tester).to\
        receive(:run).and_return(prior_result, test_result)
      allow(prior_result).to receive(:failed_winners).and_return([])
    end
    it 'raises a RuntimeError' do
      expect do
        in_learner = OTLearn::InductionLearning.new
        in_learner.grammar_tester = grammar_tester
        @in_step = in_learner.run(output_list, grammar)
      end.to raise_error(RuntimeError)
    end
  end

  context 'with one inconsistent failed winner' do
    let(:failed_winner_1) { double('failed_winner_1') }
    let(:failed_output_1) { double('output1') }
    before(:each) do
      allow(prior_result).to\
        receive(:failed_winners).and_return([failed_winner_1])
      allow(failed_winner_1).to receive(:output).and_return(failed_output_1)
      allow(consistency_checker).to receive(:mismatch_consistent?)\
        .with([failed_output_1], grammar).and_return(false)
      allow(grammar_tester).to\
        receive(:run).and_return(prior_result, test_result)
      allow(test_result).to receive(:all_correct?).and_return(true)
    end

    context 'that allows a feature to be set' do
      before(:each) do
        allow(fsf_substep).to receive(:changed?).and_return(true)
        in_learner = OTLearn::InductionLearning.new
        in_learner.consistency_checker = consistency_checker
        in_learner.grammar_tester = grammar_tester
        in_learner.fsf_learner = fsf
        @in_step = in_learner.run(output_list, grammar)
      end
      it 'reports that the grammar has changed' do
        expect(@in_step).to be_changed
      end
      it 'calls fewest set features' do
        expect(fsf).to have_received(:run)
      end
      it 'gives the fsf substep object' do
        expect(@in_step.substep).to eq fsf_substep
      end
      it 'runs a grammar test after learning' do
        expect(grammar_tester).to have_received(:run).exactly(2).times
      end
      it 'gives the grammar test result' do
        expect(@in_step.test_result).to eq test_result
      end
      it 'indicates that all words are handled correctly' do
        expect(@in_step).to be_all_correct
      end
      it 'has step type INDUCTION' do
        expect(@in_step.step_type).to eq OTLearn::INDUCTION
      end
      it 'has step subtype FEWEST_SET_FEATURES' do
        expect(@in_step.step_subtype).to eq OTLearn::FEWEST_SET_FEATURES
      end
    end

    context ' that does not allow a feature to be set' do
      before(:each) do
        allow(fsf_substep).to receive(:changed?).and_return(false)
        in_learner = OTLearn::InductionLearning.new
        in_learner.consistency_checker = consistency_checker
        in_learner.grammar_tester = grammar_tester
        in_learner.fsf_learner = fsf
        @in_step = in_learner.run(output_list, grammar)
      end
      it 'reports that the grammar has not changed' do
        expect(@in_step).not_to be_changed
      end
      it 'calls fewest set features' do
        expect(fsf).to have_received(:run)
      end
      it 'gives the fsf step object' do
        expect(@in_step.substep).to eq fsf_substep
      end
      it 'runs a grammar test after learning' do
        expect(grammar_tester).to have_received(:run).exactly(2).times
      end
      it 'gives the grammar test result' do
        expect(@in_step.test_result).to eq test_result
      end
      it 'indicates that all words are handled correctly' do
        expect(@in_step).to be_all_correct
      end
    end
  end

  context 'with one consistent failed winner' do
    let(:failed_winner_1) { double('failed_winner_1') }
    let(:failed_output_1) { double('failed_output_1') }
    before(:each) do
      allow(prior_result).to\
        receive(:failed_winners).and_return([failed_winner_1])
      allow(failed_winner_1).to receive(:output).and_return(failed_output_1)
      allow(consistency_checker).to receive(:mismatch_consistent?)\
        .with([failed_output_1], grammar).and_return(true)
      allow(grammar_tester).to\
        receive(:run).and_return(prior_result, test_result)
      allow(test_result).to receive(:all_correct?).and_return(true)
    end

    context 'that allows new ranking information' do
      before(:each) do
        # allow(mmr).to receive(:run)
        allow(mmr_substep).to receive(:changed?).and_return(true)
        in_learner = OTLearn::InductionLearning.new
        in_learner.consistency_checker = consistency_checker
        in_learner.grammar_tester = grammar_tester
        in_learner.fsf_learner = fsf
        in_learner.mmr_learner = mmr
        @in_step = in_learner.run(output_list, grammar)
      end
      it 'reports that the grammar has changed' do
        expect(@in_step).to be_changed
      end
      it 'calls max mismatch ranking' do
        expect(mmr).to have_received(:run).with([failed_output_1], grammar)
      end
      it 'gives the mmr step object' do
        expect(@in_step.substep).to eq mmr_substep
      end
      it 'runs a grammar test after learning' do
        expect(grammar_tester).to have_received(:run).exactly(2).times
      end
      it 'gives the grammar test result' do
        expect(@in_step.test_result).to eq test_result
      end
      it 'indicates that all words are handled correctly' do
        expect(@in_step).to be_all_correct
      end
      it 'has step type INDUCTION' do
        expect(@in_step.step_type).to eq OTLearn::INDUCTION
      end
      it 'has step subtype MAX_MISMATCH_RANKING' do
        expect(@in_step.step_subtype).to eq OTLearn::MAX_MISMATCH_RANKING
      end
    end
  end
end

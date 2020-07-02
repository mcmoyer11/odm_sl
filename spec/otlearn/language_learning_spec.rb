# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/language_learning'
require 'otlearn/otlearn'
require 'stringio'

RSpec.describe OTLearn::LanguageLearning do
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:ph_learner) { double('ph_learner') }
  let(:ph_step) { double('ph_step') }
  let(:sf_learner) { double('sf_learner') }
  let(:sf_step1) { double('sf_step1') }
  let(:sf_step2) { double('sf_step2') }
  let(:cp_learner) { double('cp_learner') }
  let(:cp_step) { double('cp_step') }
  let(:in_learner) { double('in_learner') }
  let(:in_step) { double('in_step') }
  before(:example) do
    allow(ph_learner).to receive(:run)
    allow(sf_learner).to receive(:run)
    allow(cp_learner).to receive(:run)
    allow(in_learner).to receive(:run)
    allow(grammar).to receive(:label)
  end

  context 'given phontactically learnable data' do
    before(:example) do
      allow(ph_learner).to receive(:run).and_return(ph_step)
      allow(ph_step).to receive(:all_correct?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.ph_learner = ph_learner
      @language_learning.sf_learner = sf_learner
      @language_learning.cp_learner = cp_learner
      @language_learning.in_learner = in_learner
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(ph_learner).to have_received(:run)
    end
    it 'has phonotactic learning as its only learning step' do
      expect(@result.step_list).to eq [ph_step]
    end
    it 'does not call single form learning' do
      expect(sf_learner).not_to have_received(:run)
    end
    it 'does not call contrast pair learning' do
      expect(cp_learner).not_to have_received(:run)
    end
    it 'does not call induction learning' do
      expect(in_learner).not_to have_received(:run)
    end
  end

  context 'given single form learnable data' do
    before(:example) do
      allow(ph_learner).to receive(:run).and_return(ph_step)
      allow(ph_step).to receive(:all_correct?).and_return(false)
      allow(sf_learner).to receive(:run).and_return(sf_step1)
      allow(sf_step1).to receive(:all_correct?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.ph_learner = ph_learner
      @language_learning.sf_learner = sf_learner
      @language_learning.cp_learner = cp_learner
      @language_learning.in_learner = in_learner
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(ph_learner).to have_received(:run)
    end
    it 'calls single form learning one time' do
      expect(sf_learner).to have_received(:run)\
        .exactly(1).times
    end
    it 'has PL and SFL learning steps' do
      expect(@result.step_list).to eq [ph_step, sf_step1]
    end
    it 'does not call contrast pair learning' do
      expect(cp_learner).not_to have_received(:run)
    end
    it 'does not call induction learning' do
      expect(in_learner).not_to have_received(:run)
    end
  end

  context 'given single contrast pair learnable data' do
    before(:example) do
      allow(ph_learner).to receive(:run).and_return(ph_step)
      allow(ph_step).to receive(:all_correct?).and_return(false)
      allow(sf_learner).to receive(:run).and_return(sf_step1, sf_step2)
      allow(sf_step1).to receive(:all_correct?).and_return(false)
      allow(sf_step2).to receive(:test_result)
      allow(sf_step2).to receive(:all_correct?).and_return(true)
      allow(cp_learner).to receive(:run).and_return(cp_step)
      allow(cp_step).to receive(:all_correct?).and_return(false)
      allow(cp_step).to receive(:changed?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.ph_learner = ph_learner
      @language_learning.sf_learner = sf_learner
      @language_learning.cp_learner = cp_learner
      @language_learning.in_learner = in_learner
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(ph_learner).to have_received(:run)
    end
    it 'calls single form learning two times' do
      expect(sf_learner).to have_received(:run).exactly(2).times
    end
    it 'has PL, SFL, CPL, and SFL learning steps' do
      expect(@result.step_list).to eq [ph_step, sf_step1, cp_step, sf_step2]
    end
    it 'calls contrast pair learning one time' do
      expect(cp_learner).to\
        have_received(:run).exactly(1).times
    end
    it 'does not call induction learning' do
      expect(in_learner).not_to have_received(:run)
    end
  end

  context 'given single induction step learnable data' do
    before(:example) do
      allow(ph_learner).to receive(:run).and_return(ph_step)
      allow(ph_step).to receive(:all_correct?).and_return(false)
      allow(sf_learner).to receive(:run).and_return(sf_step1, sf_step2)
      allow(sf_step1).to receive(:all_correct?).and_return(false)
      allow(sf_step2).to receive(:all_correct?).and_return(true)
      allow(cp_learner).to receive(:run).and_return(cp_step)
      allow(cp_step).to receive(:all_correct?).and_return(false)
      allow(cp_step).to receive(:changed?).and_return(false)
      allow(in_learner).to receive(:run).and_return(in_step)
      allow(in_step).to receive(:all_correct?).and_return(false)
      allow(in_step).to receive(:changed?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.ph_learner = ph_learner
      @language_learning.sf_learner = sf_learner
      @language_learning.cp_learner = cp_learner
      @language_learning.in_learner = in_learner
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(ph_learner).to have_received(:run)
    end
    it 'calls single form learning two times' do
      expect(sf_learner).to have_received(:run)\
        .exactly(2).times
    end
    it 'has PL, SFL, CPL, IL, and SFL learning steps' do
      expect(@result.step_list).to\
        eq [ph_step, sf_step1, cp_step, in_step, sf_step2]
    end
    it 'calls contrast pair learning one time' do
      expect(cp_learner).to\
        have_received(:run).exactly(1).times
    end
    it 'calls induction learning one time' do
      expect(in_learner).to\
        have_received(:run).exactly(1).times
    end
  end

  context 'when a RuntimeError is raised' do
    # Use StringIO as a test mock for $stderr.
    let(:warn_output) { StringIO.new }
    before(:example) do
      allow(grammar).to receive(:label).and_return('L#err')
      allow(ph_learner).to receive(:run).and_return(ph_step)
      allow(ph_step).to receive(:all_correct?).and_return(false)
      allow(sf_learner).to \
        receive(:run).and_raise(RuntimeError, 'test double error')
      @language_learning =
        OTLearn::LanguageLearning.new(warn_output: warn_output)
      @language_learning.ph_learner = ph_learner
      @language_learning.sf_learner = sf_learner
      @language_learning.cp_learner = cp_learner
      @language_learning.in_learner = in_learner
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'handles the error and constructs an error step' do
      err_step = @result.step_list[-1]
      expect(err_step.msg).to eq 'Error with L#err: test double error'
    end
    it 'has a PL learning step' do
      expect(@result.step_list).to include(ph_step)
    end
    it 'writes a warning message' do
      expect(warn_output.string).to eq\
        "Error with L#err: test double error\n"
    end
  end
end

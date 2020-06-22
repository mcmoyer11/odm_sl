# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/learning_result'

RSpec.describe 'OTLearn::LearningResult' do
  let(:step_list) { double('step list') }
  let(:grammar) { double('grammar') }
  let(:last_step) { double('last_step') }
  before(:example) do
    allow(step_list).to receive(:[]).with(-1).and_return(last_step)
    @result = OTLearn::LearningResult.new(step_list, grammar)
  end

  context 'with successful learning' do
    before(:example) do
      allow(last_step).to receive(:all_correct?).and_return(true)
    end
    it 'returns its step list' do
      expect(@result.step_list).to eq step_list
    end
    it 'returns the grammar' do
      expect(@result.grammar).to eq grammar
    end
    it 'indicates that learning was successful' do
      expect(@result.all_correct?).to be true
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/grammar_test_result'

RSpec.describe 'OTLearn::GrammarTestResult' do
  let(:failed_winners) { double('failed_winners') }
  let(:success_winners) { double('success_winners') }
  let(:grammar) { double('grammar') }
  context 'with an empty failed winner list, success winners and a grammar' do
    before(:example) do
      allow(failed_winners).to receive(:empty?).and_return(true)
      @result =
        OTLearn::GrammarTestResult.new(failed_winners, success_winners,
                                       grammar)
    end
    it 'returns the grammar' do
      expect(@result.grammar).to eq grammar
    end
    it 'returns the failed winners' do
      expect(@result.failed_winners).to eq failed_winners
    end
    it 'returns the success winners' do
      expect(@result.success_winners).to eq success_winners
    end
    it 'identifies that all winners are correct' do
      expect(@result.all_correct?).to be true
    end
  end
  context 'with failed winners' do
    before(:example) do
      allow(failed_winners).to receive(:empty?).and_return(false)
      @result =
        OTLearn::GrammarTestResult.new(failed_winners, success_winners,
                                       grammar)
    end
    it 'identifies that not all winners are correct' do
      expect(@result.all_correct?).to be false
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/consistency_checker'

RSpec.describe 'OTLearn::ConsistencyChecker' do
  let(:output) { double('output') }
  let(:word) { double('word') }
  let(:grammar) { double('grammar') }
  let(:mrcd_class) { double('MRCD class') }
  let(:mrcd_result) { double('MRCD result') }
  let(:loser_selector) { double('loser selector') }
  before(:example) do
    allow(grammar).to receive(:parse_output).and_return(word)
    allow(word).to receive(:mismatch_input_to_output!).and_return(word)
    allow(mrcd_class).to receive(:new).and_return(mrcd_result)
    @checker = OTLearn::ConsistencyChecker.new(mrcd_class: mrcd_class)
    @checker.loser_selector = loser_selector
  end

  context 'given outputs that are mismatch consistent' do
    before(:example) do
      output_list = [output]
      allow(mrcd_result).to receive(:consistent?).and_return(true)
      @result = @checker.mismatch_consistent?(output_list, grammar)
    end
    it 'parses the output into a word' do
      expect(grammar).to have_received(:parse_output).with(output)
    end
    it 'creates a mismatched input word for each output' do
      expect(word).to have_received(:mismatch_input_to_output!)
    end
    it 'calls Mrcd on the word list and grammar' do
      expect(mrcd_class).to\
        have_received(:new).with([word], grammar, loser_selector)
    end
    it 'indicates consistency' do
      expect(@result).to be true
    end
  end
  context 'given outputs that are mismatch inconsistent' do
    before(:example) do
      output_list = [output]
      allow(mrcd_result).to receive(:consistent?).and_return(false)
      @result = @checker.mismatch_consistent?(output_list, grammar)
    end
    it 'parses the output into a word' do
      expect(grammar).to have_received(:parse_output).with(output)
    end
    it 'creates a mismatched input word for each output' do
      expect(word).to have_received(:mismatch_input_to_output!)
    end
    it 'calls Mrcd on the word list and grammar' do
      expect(mrcd_class).to\
        have_received(:new).with([word], grammar, loser_selector)
    end
    it 'indicates inconsistency' do
      expect(@result).to be false
    end
  end
end

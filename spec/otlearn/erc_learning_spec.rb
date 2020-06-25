# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/erc_learning'

RSpec.describe 'OTLearn::ErcLearning' do
  let(:loser_selector) { double('loser_selector') }
  let(:mrcd_class) { double('mrcd_class') }
  let(:mrcd_result) { double('mrcd_result') }
  before(:example) do
    allow(mrcd_class).to receive(:new).and_return(mrcd_result)
    @learner = OTLearn::ErcLearning.new(mrcd_class: mrcd_class)
    @learner.loser_selector = loser_selector
  end

  context 'given a word list and a grammar' do
    let(:word_list) { double('word list') }
    let(:grammar) { double('grammar') }
    let(:new_pair) { double('new_pair') }
    let(:added_pair_list) { [new_pair] }
    before(:example) do
      allow(mrcd_result).to receive(:added_pairs).and_return(added_pair_list)
      allow(grammar).to receive(:add_erc)
      @result = @learner.run(word_list, grammar)
    end
    it 'executes MRCD on the word list' do
      expect(mrcd_class).to\
        have_received(:new).with(word_list, grammar, loser_selector)
    end
    it 'adds new ERCs to the grammar' do
      expect(grammar).to have_received(:add_erc).with(new_pair)
    end
    it 'returns the MRCD result' do
      expect(@result).to eq mrcd_result
    end
  end
end

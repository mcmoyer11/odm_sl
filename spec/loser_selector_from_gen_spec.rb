# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'loser_selector_from_gen'

RSpec.describe 'LoserSelectorFromGen' do
  let(:system) { double('system') }
  let(:selector) { double('selector') }
  let(:winner) { double('winner') }
  let(:input) { double('input') }
  let(:competition) { double('competition') }
  let(:loser_result) { double('loser_result') }
  before(:each) do
    allow(winner).to receive(:input).and_return(input)
    allow(system).to receive(:gen).with(input).and_return(competition)
    allow(selector).to receive(:select_loser).and_return(loser_result)
    @gselector = LoserSelectorFromGen.new(system, selector)
  end

  context 'given a winner and ranking information' do
    let(:ranking_info) { double('ranking_info') }
    before(:each) do
      @loser = @gselector.select_loser(winner, ranking_info)
    end
    it 'computes the competition using Gen' do
      expect(system).to have_received(:gen).with(input)
    end
    it 'calls the selector with the generated competition' do
      expect(selector).to have_received(:select_loser) \
        .with(winner, competition, ranking_info)
    end
    it 'returns the loser/nil returned by the selector' do
      expect(@loser).to eq loser_result
    end
  end
end

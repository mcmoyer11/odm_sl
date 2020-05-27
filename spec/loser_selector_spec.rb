# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'loser_selector'

RSpec.describe 'LoserSelector' do
  let(:winner) { double('winner') }
  let(:ranking_info) { double('ranking info') }
  let(:comparer) { double('comparer') }
  before(:each) do
    @selector = LoserSelector.new(comparer)
  end

  context 'given a competition with only the winner' do
    before(:each) do
      competition = [winner]
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, winner, ranking_info) \
        .and_return(:IDENT_VIOLATIONS)
      @loser = @selector.select_loser(winner, competition, ranking_info)
    end
    it 'returns nil' do
      expect(@loser).to be nil
    end
  end

  context 'given a candidate more harmonic than the winner' do
    let(:moreh) { double('more harmonic') }
    before(:each) do
      competition = [winner, moreh]
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, winner, ranking_info) \
        .and_return(:IDENT_VIOLATIONS)
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, moreh, ranking_info) \
        .and_return(:COMPETITOR)
      @loser = @selector.select_loser(winner, competition, ranking_info)
    end
    it 'returns the competitor' do
      expect(@loser).to eq moreh
    end
  end

  context 'given a candidate less harmonic than the winner' do
    let(:lessh) { double('less harmonic') }
    before(:each) do
      competition = [lessh, winner]
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, winner, ranking_info) \
        .and_return(:IDENT_VIOLATIONS)
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, lessh, ranking_info) \
        .and_return(:WINNER)
      @loser = @selector.select_loser(winner, competition, ranking_info)
    end
    it 'returns nil' do
      expect(@loser).to be nil
    end
  end

  context 'given a candidate distinct but with identical violations' do
    let(:ident_viols) { double('identical violations') }
    before(:each) do
      competition = [winner, ident_viols]
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, winner, ranking_info) \
        .and_return(:IDENT_VIOLATIONS)
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, ident_viols, ranking_info) \
        .and_return(:IDENT_VIOLATIONS)
      @loser = @selector.select_loser(winner, competition, ranking_info)
    end
    it 'returns nil' do
      expect(@loser).to be nil
    end
  end

  context 'given two candidates more harmonic than the winner' do
    let(:lessh) { double('less harmonic') }
    let(:moreh1) { double('more harmonic1') }
    let(:moreh2) { double('more harmonic2') }
    before(:each) do
      competition = [lessh, moreh1, winner, moreh2]
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, winner, ranking_info) \
        .and_return(:IDENT_VIOLATIONS)
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, moreh1, ranking_info) \
        .and_return(:COMPETITOR)
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, moreh2, ranking_info) \
        .and_return(:COMPETITOR)
      allow(comparer).to receive(:more_harmonic) \
        .with(winner, lessh, ranking_info) \
        .and_return(:WINNER)
      @loser = @selector.select_loser(winner, competition, ranking_info)
    end
    it 'returns the competitor' do
      expect(@loser).to eq moreh1
    end
  end
end

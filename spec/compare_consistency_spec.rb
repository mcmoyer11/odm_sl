# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'erc_list'
require 'win_lose_pair'
require 'compare_consistency'

RSpec.describe 'CompareConsistency' do
  let(:winner) { double('winner') }
  let(:competitor) { double('competitor') }
  let(:param_ercs) { double('parameter Ercs') }
  let(:erc_list_class) { double('erc_list_class') }
  let(:erc_list) { instance_double(ErcList, 'erc_list') }
  let(:win_lose_pair_class) { double('win_lose_pair_class') }
  let(:wl_pair) { instance_double(Win_lose_pair, 'wl_pair') }
  before(:example) do
    allow(erc_list_class).to receive(:new).and_return(erc_list)
    allow(win_lose_pair_class).to receive(:new).with(competitor, winner).and_return(wl_pair)
    allow(erc_list).to receive(:add_all).with(param_ercs).and_return(erc_list)
    allow(erc_list).to receive(:add).with(wl_pair).and_return(erc_list)
    @comparer = CompareConsistency.new(
      erc_list_class: erc_list_class,
      win_lose_pair_class: win_lose_pair_class)
  end

  context 'given a consistent competitor' do
    before(:example) do
      allow(winner).to receive(:ident_viols?).with(competitor) \
                                             .and_return(false)
      allow(erc_list).to receive(:consistent?).and_return(true)
      @code = @comparer.more_harmonic(winner, competitor, param_ercs)
    end
    it 'returns :SECOND' do
      expect(@code).to eq :SECOND
    end
  end

  context 'given an inconsistent competitor' do
    before(:example) do
      allow(winner).to receive(:ident_viols?).with(competitor) \
                                             .and_return(false)
      allow(erc_list).to receive(:consistent?).and_return(false)
      @code = @comparer.more_harmonic(winner, competitor, param_ercs)
    end
    it 'returns :FIRST' do
      expect(@code).to eq :FIRST
    end
  end

  context 'given a competitor with identical violations' do
    before(:example) do
      allow(winner).to receive(:ident_viols?).with(competitor) \
                                             .and_return(true)
      @code = @comparer.more_harmonic(winner, competitor, param_ercs)
    end
    it 'returns :FIRST' do
      expect(@code).to eq :IDENT_VIOLATIONS
    end
  end
end

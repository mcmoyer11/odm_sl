# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'compare_ctie'

RSpec.describe 'CompareCtie' do
  let(:winner) { double('winner') }
  let(:competitor) { double('competitor') }
  let(:param_ercs) { double('parameter Ercs') }
  let(:ranker) { double('ranker') }
  let(:stratum1) { double('stratum1') }
  let(:stratum2) { double('stratum2') }
  let(:stratum3) { double('stratum3') }
  let(:hierarchy) { double('hierarchy') }
  let(:stratum_comparer) { double('stratum_comparer') }
  before do
    allow(ranker).to receive(:get_hierarchy).with(param_ercs)\
                                            .and_return(hierarchy)
    allow(hierarchy).to receive(:each).and_yield(stratum1)\
                                      .and_yield(stratum2)\
                                      .and_yield(stratum3)
    @comparer = CompareCtie.new(ranker, stratum_comparer: stratum_comparer)
  end

  context 'given a competitor less harmonic on the 2nd stratum' do
    before(:each) do
      allow(winner).to receive(:ident_viols?).and_return(false)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(winner, competitor, stratum1).and_return(:IDENT_VIOLATIONS)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(winner, competitor, stratum2).and_return(:FIRST)
      @code = @comparer.more_harmonic(winner, competitor, param_ercs)
    end
    it 'generates a ranking with the ranker' do
      expect(ranker).to have_received(:get_hierarchy).with(param_ercs)
    end
    it 'calls the stratum_comparer with the first stratum' do
      expect(stratum_comparer).to have_received(:more_harmonic)\
        .with(winner, competitor, stratum1)
    end
    it 'calls the stratum_comparer with the second stratum' do
      expect(stratum_comparer).to have_received(:more_harmonic)\
        .with(winner, competitor, stratum2)
    end
    it 'returns :FIRST' do
      expect(@code).to eq :FIRST
    end
  end
  context 'given a competitor more harmonic on the first stratum' do
    before(:each) do
      allow(winner).to receive(:ident_viols?).and_return(false)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(winner, competitor, stratum1).and_return(:SECOND)
      @code = @comparer.more_harmonic(winner, competitor, param_ercs)
    end
    it 'returns :SECOND' do
      expect(@code).to eq :SECOND
    end
  end
  context 'given a competitor that conflicts on the first stratum' do
    before(:each) do
      allow(winner).to receive(:ident_viols?).and_return(false)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(winner, competitor, stratum1).and_return(:CONFLICT)
      @code = @comparer.more_harmonic(winner, competitor, param_ercs)
    end
    it 'returns :TIE' do
      expect(@code).to eq :TIE
    end
  end
  context 'given a competitor with identical violations' do
    before(:each) do
      allow(winner).to receive(:ident_viols?).and_return(true)
      allow(stratum_comparer).to receive(:more_harmonic)
      @code = @comparer.more_harmonic(winner, competitor, param_ercs)
    end
    it 'returns :IDENT_VIOLATIONS' do
      expect(@code).to eq :IDENT_VIOLATIONS
    end
  end
  context 'given candidates with distinct violations yet tie on all strata' do
    before(:each) do
      allow(winner).to receive(:ident_viols?).and_return(false)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(winner, competitor, stratum1).and_return(:IDENT_VIOLATIONS)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(winner, competitor, stratum2).and_return(:IDENT_VIOLATIONS)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(winner, competitor, stratum3).and_return(:IDENT_VIOLATIONS)
    end
    it 'raises an exception' do
      expect { @comparer.more_harmonic(winner, competitor, param_ercs) }\
        .to raise_error(RuntimeError)
    end
  end
end

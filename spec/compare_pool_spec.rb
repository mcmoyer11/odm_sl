# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'compare_pool'

RSpec.describe 'ComparePool' do
  let(:first) { double('first candidate') }
  let(:second) { double('second candidate') }
  let(:param_ercs) { double('parameter Ercs') }
  let(:ranker) { double('ranker') }
  let(:stratum1) { double('stratum1') }
  let(:stratum2) { double('stratum2') }
  let(:stratum3) { double('stratum3') }
  let(:hierarchy) { double('hierarchy') }
  let(:stratum_comparer) { double('stratum_comparer') }
  before(:example) do
    allow(ranker).to receive(:get_hierarchy).with(param_ercs)\
                                            .and_return(hierarchy)
    allow(hierarchy).to receive(:each).and_yield(stratum1)\
                                      .and_yield(stratum2)\
                                      .and_yield(stratum3)
    @comparer = ComparePool.new(ranker,
                                stratum_comparer: stratum_comparer)
  end

  context 'when the first candidate is more harmonic on the second stratum' do
    before(:example) do
      allow(first).to receive(:ident_viols?).and_return(false)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(first, second, stratum1).and_return(:TIE)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(first, second, stratum2).and_return(:FIRST)
    end
    context 'with ercs' do
      before(:example) do
        @code = @comparer.more_harmonic(first, second, param_ercs)
      end
      it 'generates a ranking with the ranker' do
        expect(ranker).to have_received(:get_hierarchy).with(param_ercs)
      end
      it 'calls the stratum_comparer with the first stratum' do
        expect(stratum_comparer).to have_received(:more_harmonic)\
          .with(first, second, stratum1)
      end
      it 'calls the stratum_comparer with the second stratum' do
        expect(stratum_comparer).to have_received(:more_harmonic)\
          .with(first, second, stratum2)
      end
      it 'returns :FIRST' do
        expect(@code).to eq :FIRST
      end
    end
    context 'with a hierarchy' do
      before(:example) do
        @code = @comparer.more_harmonic_on_hierarchy(first, second, hierarchy)
      end
      it 'does not generates a ranking' do
        expect(ranker).not_to have_received(:get_hierarchy)
      end
      it 'calls the stratum_comparer with the first stratum' do
        expect(stratum_comparer).to have_received(:more_harmonic)\
          .with(first, second, stratum1)
      end
      it 'calls the stratum_comparer with the second stratum' do
        expect(stratum_comparer).to have_received(:more_harmonic)\
          .with(first, second, stratum2)
      end
      it 'returns :FIRST' do
        expect(@code).to eq :FIRST
      end
    end
  end
  context 'when the second candidate is more harmonic on the first stratum' do
    before(:example) do
      allow(first).to receive(:ident_viols?).and_return(false)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(first, second, stratum1).and_return(:SECOND)
    end
    context 'with ercs' do
      before(:example) do
        @code = @comparer.more_harmonic(first, second, param_ercs)
      end
      it 'returns :SECOND' do
        expect(@code).to eq :SECOND
      end
    end
    context 'with a hierarchy' do
      before(:example) do
        @code = @comparer.more_harmonic_on_hierarchy(first, second, hierarchy)
      end
      it 'returns :SECOND' do
        expect(@code).to eq :SECOND
      end
    end
  end
  context 'when candidates have distinct violations but tie on all strata' do
    before(:example) do
      allow(first).to receive(:ident_viols?).and_return(false)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(first, second, stratum1).and_return(:TIE)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(first, second, stratum2).and_return(:TIE)
      allow(stratum_comparer).to receive(:more_harmonic)\
        .with(first, second, stratum3).and_return(:TIE)
    end
    context 'with ercs' do
      before(:example) do
        @code = @comparer.more_harmonic(first, second, param_ercs)
      end
      it 'returns :TIE' do
        expect(@code).to eq :TIE
      end
    end
    context 'with a hierarchy' do
      before(:example) do
        @code = @comparer.more_harmonic_on_hierarchy(first, second, hierarchy)
      end
      it 'returns :TIE' do
        expect(@code).to eq :TIE
      end
    end
  end
  context 'when the candidates have identical violation profiles' do
    before(:example) do
      allow(first).to receive(:ident_viols?).and_return(true)
    end
    context 'with ercs' do
      before(:example) do
        @code = @comparer.more_harmonic(first, second, param_ercs)
      end
      it 'returns :IDENT_VIOLATIONS' do
        expect(@code).to eq :IDENT_VIOLATIONS
      end
    end
    context 'with a hierarchy' do
      before(:example) do
        @code = @comparer.more_harmonic_on_hierarchy(first, second, hierarchy)
      end
      it 'returns :IDENT_VIOLATIONS' do
        expect(@code).to eq :IDENT_VIOLATIONS
      end
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'compare_stratum_ctie'

RSpec.describe 'CompareStratumCtie' do
  let(:first) { double('first') }
  let(:second) { double('second') }
  let(:win_lose_pair_class) { double('win_lose_pair_class') }
  let(:wl_pair) { double('wl_pair') }
  let(:con1) { double('constraint1') }
  let(:con2) { double('constraint2') }
  let(:con3) { double('constraint3') }
  before(:example) do
    @comparer =
      CompareStratumCtie.new(win_lose_pair_class: win_lose_pair_class)
    allow(win_lose_pair_class).to receive(:new).with(first, second)\
                                               .and_return(wl_pair)
  end

  context 'when candidates have identical violations on the stratum' do
    before(:example) do
      stratum = [con1, con2, con3]
      allow(wl_pair).to receive(:l?).and_return(false)
      allow(wl_pair).to receive(:w?).and_return(false)
      @code = @comparer.more_harmonic(first, second, stratum)
    end
    it 'returns :IDENT_VIOLATIONS' do
      expect(@code).to eq :IDENT_VIOLATIONS
    end
  end
  context 'when first is better on con2, equal on con1 and con3' do
    before(:example) do
      stratum = [con1, con2, con3]
      allow(wl_pair).to receive(:l?).and_return(false)
      allow(wl_pair).to receive(:w?).and_return(false)
      allow(wl_pair).to receive(:w?).with(con2).and_return(true)
      @code = @comparer.more_harmonic(first, second, stratum)
    end
    it 'returns :FIRST' do
      expect(@code).to eq :FIRST
    end
  end
  context 'when second is better on con1, equal on con2 and con3' do
    before(:example) do
      stratum = [con1, con2, con3]
      # Note: the allow statements for a method must be ordered from general
      # to specific; otherwise the later-declared general overrides.
      allow(wl_pair).to receive(:l?).and_return(false)
      allow(wl_pair).to receive(:l?).with(con1).and_return(true)
      allow(wl_pair).to receive(:w?).and_return(false)
      @code = @comparer.more_harmonic(first, second, stratum)
    end
    it 'returns :SECOND' do
      expect(@code).to eq :SECOND
    end
  end
  context 'when first is better on con1, second is better on con2 and con3' do
    before(:example) do
      stratum = [con1, con2, con3]
      allow(wl_pair).to receive(:l?).with(con1).and_return(false)
      allow(wl_pair).to receive(:l?).with(con2).and_return(true)
      allow(wl_pair).to receive(:l?).with(con3).and_return(true)
      allow(wl_pair).to receive(:w?).with(con1).and_return(true)
      allow(wl_pair).to receive(:w?).with(con2).and_return(false)
      allow(wl_pair).to receive(:w?).with(con3).and_return(false)
      @code = @comparer.more_harmonic(first, second, stratum)
    end
    it 'returns :CONFLICT' do
      expect(@code).to eq :CONFLICT
    end
  end
end

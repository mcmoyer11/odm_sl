# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'compare_stratum_pool'

RSpec.describe 'CompareStratumPool' do
  let(:first) { double('first candidate') }
  let(:second) { double('second candidate') }
  let(:con1) { double('constraint1') }
  let(:con2) { double('constraint2') }
  let(:con3) { double('constraint3') }
  before(:example) do
    @comparer = CompareStratumPool.new
  end

  context 'when first has fewer violations on a single constraint' do
    before(:example) do
      stratum = [con1]
      allow(first).to receive(:get_viols).with(con1).and_return(0)
      allow(second).to receive(:get_viols).with(con1).and_return(1)
      @code = @comparer.more_harmonic(first, second, stratum)
    end
    it 'returns :FIRST' do
      expect(@code).to eq :FIRST
    end
  end
  context 'when second has fewer violations over three constraints' do
    before(:example) do
      stratum = [con1, con2, con3]
      allow(first).to receive(:get_viols).with(con1).and_return(0)
      allow(first).to receive(:get_viols).with(con2).and_return(3)
      allow(first).to receive(:get_viols).with(con3).and_return(2)
      allow(second).to receive(:get_viols).with(con1).and_return(1)
      allow(second).to receive(:get_viols).with(con2).and_return(0)
      allow(second).to receive(:get_viols).with(con3).and_return(2)
      @code = @comparer.more_harmonic(first, second, stratum)
    end
    it 'returns :SECOND' do
      expect(@code).to eq :SECOND
    end
  end
  context 'when the candidates equal violation counts over three constraints' do
    before(:example) do
      stratum = [con1, con2, con3]
      allow(first).to receive(:get_viols).with(con1).and_return(0)
      allow(first).to receive(:get_viols).with(con2).and_return(1)
      allow(first).to receive(:get_viols).with(con3).and_return(2)
      allow(second).to receive(:get_viols).with(con1).and_return(1)
      allow(second).to receive(:get_viols).with(con2).and_return(2)
      allow(second).to receive(:get_viols).with(con3).and_return(0)
      @code = @comparer.more_harmonic(first, second, stratum)
    end
    it 'returns :TIE' do
      expect(@code).to eq :TIE
    end
  end
end

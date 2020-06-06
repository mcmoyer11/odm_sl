# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'eval'

RSpec.describe 'Eval' do
  let(:hier) { double('hierarchy') }
  let(:comparer) { double('comparer') }
  context 'given a competition with only one candidate' do
    let(:cand1) { double('cand1') }
    before(:example) do
      @comp = [cand1]
      @eval = Eval.new(comparer)
    end
    it 'returns the candidate' do
      expect(@eval.find_optima(@comp, hier)).to contain_exactly(cand1)
    end
  end
  context 'given a more harmonic candidate with others' do
    let(:lessh) { double('lessh') }
    let(:moreh) { double('moreh') }
    before(:example) do
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(lessh, moreh, hier).and_return(:SECOND)
      @comp = [lessh, moreh]
      @eval = Eval.new(comparer)
    end
    it 'returns the more harmonic candidate' do
      expect(@eval.find_optima(@comp, hier)).to contain_exactly(moreh)
    end
  end
  context 'given two identical violation candidates that are more harmonic' do
    let(:ident1) { double('ident1') }
    let(:ident2) { double('ident2') }
    let(:noopt1) { double('noopt1') }
    let(:noopt2) { double('noopt2') }
    before(:example) do
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(ident1, noopt1, hier).and_return(:FIRST)
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(ident1, ident2, hier).and_return(:IDENT_VIOLATIONS)
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(ident1, noopt2, hier).and_return(:FIRST)
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(ident2, noopt2, hier).and_return(:FIRST)
      @comp = [ident1, noopt1, ident2, noopt2]
      @eval = Eval.new(comparer)
    end
    it 'returns both identical violation candidates' do
      expect(@eval.find_optima(@comp, hier)).to contain_exactly(ident1, ident2)
    end
  end
  context 'given tied candidates that are more harmonic' do
    let(:tie1) { double('tie1') }
    let(:tie2) { double('tie2') }
    let(:noopt1) { double('noopt1') }
    let(:noopt2) { double('noopt2') }
    before(:example) do
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(tie1, noopt1, hier).and_return(:FIRST)
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(tie1, tie2, hier).and_return(:TIE)
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(tie1, noopt2, hier).and_return(:FIRST)
      allow(comparer).to receive(:more_harmonic_on_hierarchy)\
        .with(tie2, noopt2, hier).and_return(:FIRST)
      @comp = [tie1, noopt1, tie2, noopt2]
      @eval = Eval.new(comparer)
    end
    it 'returns the tied candidates' do
      expect(@eval.find_optima(@comp, hier)).to contain_exactly(tie1, tie2)
    end
  end
  context 'given an empty candidate list' do
    before(:example) do
      @comp = []
      @eval = Eval.new(comparer)
    end
    it 'returns an empty optima list' do
      expect(@eval.find_optima(@comp, hier)).to be_empty
    end
  end
end

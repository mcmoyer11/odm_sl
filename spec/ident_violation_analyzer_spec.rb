# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'ident_violation_analyzer'

RSpec.describe IdentViolationAnalyzer do

  context 'given a competition with no ident candidates' do
    let(:cand1) { double('candidate1') }
    let(:cand2) { double('candidate2') }
    before(:each) do
      allow(cand1).to receive(:ident_viols?).with(cand2).and_return(false)
      competition = [cand1, cand2]
      @analyzer = IdentViolationAnalyzer.new(competition)
    end
    it 'indicates no duplicates' do
      expect(@analyzer.ident_viol_candidates?).to be false
    end
  end
  context 'given a competition with 2 ident candidates' do
    let(:cand1a) { double('candidate1a') }
    let(:cand1b) { double('candidate1b') }
    let(:cand2) { double('candidate2') }
    before(:each) do
      allow(cand1a).to receive(:ident_viols?).with(cand1b).and_return(true)
      allow(cand1a).to receive(:ident_viols?).with(cand2).and_return(false)
      competition = [cand1a, cand2, cand1b]
      @analyzer = IdentViolationAnalyzer.new(competition)
    end
    it 'indicates duplicates' do
      expect(@analyzer.ident_viol_candidates?).to be true
    end
    it 'has a part containing the unique candidate only' do
      expect(@analyzer.include?([cand2])).to be true
    end
    it 'has a part containing both ident candidates' do
      expect(@analyzer.include?([cand1a, cand1b])).to be true
    end
    it 'returns a list with just the part containing the ident candidates' do
      expect(@analyzer.duplicate_viol_candidates).to eq [[cand1a, cand1b]]
    end
  end
end

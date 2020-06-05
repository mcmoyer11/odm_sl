# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'ranker'

RSpec.describe 'Ranker' do
  let(:rcd_runner) { double('rcd_runner') }
  let(:rcd_obj) { double('rcd_obj') }
  let(:rcd_hierarchy) { double('rcd_hierarchy') }
  let(:ercs) { double('ercs') }
  before(:example) do
    allow(rcd_runner).to receive(:run_rcd).with(ercs).and_return(rcd_obj)
    allow(rcd_obj).to receive(:hierarchy).and_return(rcd_hierarchy)
    @ranker = Ranker.new(rcd_runner)
  end

  context 'when called with ercs' do
    before(:example) do
      @hierarchy = @ranker.get_hierarchy(ercs)
    end
    it 'creates a new RCD object with the ercs' do
      expect(rcd_runner).to have_received(:run_rcd).with(ercs)
    end
    it 'returns the hierarchy produced by RCD' do
      expect(@hierarchy).to eq rcd_hierarchy
    end
  end
end

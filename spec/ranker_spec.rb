# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'ranker'

RSpec.describe 'Ranker' do
  let(:rcd_class) { double('rcd_class') }
  let(:rcd_obj) { double('rcd_obj') }
  let(:rcd_hierarchy) { double('rcd_hierarchy') }
  let(:ercs) { double('ercs') }
  before(:example) do
    allow(rcd_class).to receive(:new).with(ercs).and_return(rcd_obj)
    allow(rcd_obj).to receive(:hierarchy).and_return(rcd_hierarchy)
    @ranker = Ranker.new(rcd_class)
  end

  context 'when called with ercs' do
    before(:example) do
      @hierarchy = @ranker.get_hierarchy(ercs)
    end
    it 'creates a new RCD object with the ercs' do
      expect(rcd_class).to have_received(:new).with(ercs)
    end
    it 'returns the hierarchy produced by RCD' do
      expect(@hierarchy).to eq rcd_hierarchy
    end
  end
end

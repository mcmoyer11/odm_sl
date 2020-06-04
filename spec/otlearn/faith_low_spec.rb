# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/faith_low'
require 'constraint'

RSpec.describe 'FaithLow' do
  let(:con) { instance_double(Constraint, 'constraint') }
  before(:example) do
    @kind = OTLearn::FaithLow.new
  end

  context 'given a faithfulness constraint' do
    before(:example) do
      allow(con).to receive(:faithfulness?).and_return(true)
    end
    it 'returns true' do
      expect(@kind.member?(con)).to be true
    end
  end
  context 'given a non-faithfulness constraint' do
    before(:example) do
      allow(con).to receive(:faithfulness?).and_return(false)
    end
    it 'returns false' do
      expect(@kind.member?(con)).to be false
    end
  end
end

# Author: Bruce Tesar

require 'rspec'
require_relative '../lib/factorial_typology'

RSpec.describe 'FactorialTypology' do
  let(:comp_list) { double('comp_list') }
  before do
    # Do nothing
  end

  context 'given a competition list' do
    before(:each) do
      allow(comp_list).to receive(:constraint_list)
      allow(comp_list).to receive(:each)
      allow(comp_list).to receive(:label).and_return('comp_list_label')
      @factyp = FactorialTypology.new(comp_list)
    end
    it 'provides the original competition list' do
      expect(@factyp.competition_list).to eq comp_list
    end
  end
end

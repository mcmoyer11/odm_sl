# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'ranking_bias_all_high'

RSpec.describe 'RankingBiasAllHigh' do
  let(:rcd) { double('rcd') }
  let(:con1) { double('constraint1') }
  let(:con2) { double('constraint2') }
  before(:example) do
    @rankable = [con1, con2]
    @bias = RankingBiasAllHigh.new
  end

  context 'given rankable constraints' do
    before(:example) do
      @returned_constraints = @bias.choose_cons_to_rank(@rankable, rcd)
    end
    it 'returns all rankable constraints' do
      expect(@returned_constraints).to eq @rankable
    end
  end
end

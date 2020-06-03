# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'constraint'
require 'otlearn/ranking_bias_some_low'
require_relative '../../test/helpers/quick_erc'

RSpec.describe 'OTLearn::RankingBiasSomeLow' do
  let(:rcd) { double('rcd') }
  let(:low_kind) { double('low constraint kind') }
  let(:con1) { instance_double(Constraint, 'Constraint1') }
  let(:con2) { instance_double(Constraint, 'Constraint2') }
  let(:con3) { instance_double(Constraint, 'Constraint3') }
  let(:con4) { instance_double(Constraint, 'Constraint4') }
  let(:con5) { instance_double(Constraint, 'Constraint5') }
  before(:example) do
    stub_const 'ML', Test::ML
    stub_const 'ME', Test::ME
    stub_const 'MW', Test::MW
    stub_const 'FL', Test::FL
    stub_const 'FE', Test::FE
    stub_const 'FW', Test::FW
    @bias = OTLearn::RankingBiasSomeLow.new(low_kind)
  end
  context 'all rankable constraints are the high kind' do
    before(:example) do
      allow(low_kind).to receive(:member?).with(con1).and_return(false)
      allow(low_kind).to receive(:member?).with(con2).and_return(false)
      allow(low_kind).to receive(:member?).with(con3).and_return(false)
      @rankable = [con2, con3]
      @chosen = @bias.choose_cons_to_rank(@rankable, rcd)
    end
    it 'returns all of the rankable constraints' do
      expect(@chosen).to eq @rankable
    end
  end

  context 'some rankable constraints are the high kind' do
    before(:example) do
      allow(low_kind).to receive(:member?).with(con1).and_return(false)
      allow(low_kind).to receive(:member?).with(con2).and_return(true)
      allow(low_kind).to receive(:member?).with(con3).and_return(false)
      @rankable = [con2, con3]
      @chosen = @bias.choose_cons_to_rank(@rankable, rcd)
    end
    it 'returns only the high kind ones' do
      expect(@chosen).to eq [con3]
    end
  end

  context 'two low constraints are not active' do
    let(:erc1) { double('erc1') }
    before(:example) do
      allow(erc1).to receive(:w?).with(con1).and_return(false)
      allow(erc1).to receive(:w?).with(con2).and_return(false)
      unex_ercs = [erc1]
      allow(rcd).to receive(:unex_ercs).and_return(unex_ercs)
      allow(low_kind).to receive(:member?).with(con1).and_return(true)
      allow(low_kind).to receive(:member?).with(con2).and_return(true)
      @rankable = [con1, con2]
      @chosen = @bias.choose_cons_to_rank(@rankable, rcd)
    end
    it 'returns all the inactive ones' do
      expect(@chosen).to eq [con1, con2]
    end
  end

  context 'one low kind is active, one is not' do
    let(:erc1) { double('erc1') }
    let(:erc2) { double('erc2') }
    before(:example) do
      allow(erc1).to receive(:w?).with(con1).and_return(true)
      allow(erc1).to receive(:l?).with(con1).and_return(false)
      allow(erc1).to receive(:w?).with(con2).and_return(false)
      allow(erc1).to receive(:l?).with(con2).and_return(false)
      allow(erc2).to receive(:w?).with(con1).and_return(false)
      allow(erc2).to receive(:l?).with(con1).and_return(false)
      allow(erc2).to receive(:w?).with(con2).and_return(false)
      allow(erc2).to receive(:l?).with(con2).and_return(false)
      unex_ercs = [erc1, erc2]
      allow(rcd).to receive(:unex_ercs).and_return(unex_ercs)
      allow(low_kind).to receive(:member?).with(con1).and_return(true)
      allow(low_kind).to receive(:member?).with(con2).and_return(true)
      @rankable = [con1, con2]
      allow(rcd).to receive(:unranked).and_return([con1, con2])
      @chosen = @bias.choose_cons_to_rank(@rankable, rcd)
    end
    it 'returns the active one' do
      expect(@chosen).to eq [con1]
    end
  end

  context 'one low kind frees up two high kind, another only frees up one' do
    let(:erc1) { double('erc1') }
    let(:erc2) { double('erc2') }
    before(:example) do
      allow(erc1).to receive(:w?).with(con1).and_return(false)
      allow(erc1).to receive(:l?).with(con1).and_return(true)
      allow(erc1).to receive(:w?).with(con2).and_return(true)
      allow(erc1).to receive(:l?).with(con2).and_return(false)
      allow(erc1).to receive(:w?).with(con3).and_return(false)
      allow(erc1).to receive(:l?).with(con3).and_return(false)
      allow(erc1).to receive(:w?).with(con4).and_return(true)
      allow(erc1).to receive(:l?).with(con4).and_return(false)
      allow(erc2).to receive(:w?).with(con1).and_return(false)
      allow(erc2).to receive(:l?).with(con1).and_return(false)
      allow(erc2).to receive(:w?).with(con2).and_return(true)
      allow(erc2).to receive(:l?).with(con2).and_return(false)
      allow(erc2).to receive(:w?).with(con3).and_return(false)
      allow(erc2).to receive(:l?).with(con3).and_return(true)
      allow(erc2).to receive(:w?).with(con4).and_return(false)
      allow(erc2).to receive(:l?).with(con4).and_return(false)
      unex_ercs = [erc1, erc2]
      allow(rcd).to receive(:unex_ercs).and_return(unex_ercs)
      allow(low_kind).to receive(:member?).with(con1).and_return(false)
      allow(low_kind).to receive(:member?).with(con2).and_return(true)
      allow(low_kind).to receive(:member?).with(con3).and_return(false)
      allow(low_kind).to receive(:member?).with(con4).and_return(true)
      @rankable = [con2, con4]
      unranked = [con1, con2, con3, con4]
      allow(rcd).to receive(:unranked).and_return(unranked)
      @chosen = @bias.choose_cons_to_rank(@rankable, rcd)
    end
    it 'returns the one freeing up two high kind' do
      expect(@chosen).to eq [con2]
    end
  end

  # Accounting for effect of order in which the constraints appear
  # in the list.
  context 'one low kind frees up one high kind, another frees up two' do
    let(:erc1) { double('erc1') }
    let(:erc2) { double('erc2') }
    before(:example) do
      allow(erc1).to receive(:w?).with(con1).and_return(false)
      allow(erc1).to receive(:l?).with(con1).and_return(true)
      allow(erc1).to receive(:w?).with(con2).and_return(true)
      allow(erc1).to receive(:l?).with(con2).and_return(false)
      allow(erc1).to receive(:w?).with(con3).and_return(false)
      allow(erc1).to receive(:l?).with(con3).and_return(false)
      allow(erc1).to receive(:w?).with(con4).and_return(true)
      allow(erc1).to receive(:l?).with(con4).and_return(false)
      allow(erc2).to receive(:w?).with(con1).and_return(false)
      allow(erc2).to receive(:l?).with(con1).and_return(false)
      allow(erc2).to receive(:w?).with(con2).and_return(false)
      allow(erc2).to receive(:l?).with(con2).and_return(false)
      allow(erc2).to receive(:w?).with(con3).and_return(false)
      allow(erc2).to receive(:l?).with(con3).and_return(true)
      allow(erc2).to receive(:w?).with(con4).and_return(true)
      allow(erc2).to receive(:l?).with(con4).and_return(false)
      unex_ercs = [erc1, erc2]
      allow(rcd).to receive(:unex_ercs).and_return(unex_ercs)
      allow(low_kind).to receive(:member?).with(con1).and_return(false)
      allow(low_kind).to receive(:member?).with(con2).and_return(true)
      allow(low_kind).to receive(:member?).with(con3).and_return(false)
      allow(low_kind).to receive(:member?).with(con4).and_return(true)
      @rankable = [con2, con4]
      unranked = [con1, con2, con3, con4]
      allow(rcd).to receive(:unranked).and_return(unranked)
      @chosen = @bias.choose_cons_to_rank(@rankable, rcd)
    end
    it 'returns the one freeing up two high kind' do
      expect(@chosen).to eq [con4]
    end
  end

  context 'one low kind frees up a size two high kind cascade'

  context 'no single low kind frees a high kind'

end

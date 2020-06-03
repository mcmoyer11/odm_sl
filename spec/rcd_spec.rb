# frozen_string_literal: true

# Author: Bruce Tesar
#
# The specs for class Rcd make use of a test helper, Test.quick_erc.
# This helper, in turn, explicitly uses the following production classes:
# * Erc
# * Constraint

require 'rcd'
require 'erc_list'
require_relative '../test/helpers/quick_erc'

RSpec.describe Rcd do
  let(:erc_list) { instance_double(ErcList, 'ERC list') }
  before(:example) do
    stub_const 'ML', Test::ML
    stub_const 'ME', Test::ME
    stub_const 'MW', Test::MW
    stub_const 'FL', Test::FL
    stub_const 'FE', Test::FE
    stub_const 'FW', Test::FW
  end

  context 'with an empty ERC list and 2 constraints' do
    let(:con1) { 'C1' }
    let(:con2) { 'C2' }
    let(:constraint_list) { [con1, con2] }
    before(:example) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each)
      @rcd = Rcd.new(erc_list)
    end
    it 'is consistent' do
      expect(@rcd).to be_consistent
    end
    it 'has a list of all the constraints' do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it 'has a hierarchy with all constraints in the top stratum' do
      expect(@rcd.hierarchy).to eq [[con1, con2]]
    end
    it 'has ranked constraints with all constraints in the top stratum' do
      expect(@rcd.ranked.to_a).to eq [[con1, con2]]
    end
    it 'has no unranked constraints' do
      expect(@rcd.unranked).to be_empty
    end
    it 'has an empty list of the ERCs passed in' do
      expect(@rcd.erc_list).to be_empty
    end
    it 'returns an ErcList of ERCs passed in' do
      expect(@rcd.erc_list).to be_a_kind_of(ErcList)
    end
    it 'has no explained ERCs' do
      expect(@rcd.ex_ercs).to eq [[]]
    end
    it 'has no unexplained ercs' do
      expect(@rcd.unex_ercs).to be_empty
    end
  end

  context 'with ERC list [[ML,MW]]' do
    let(:erc1) { Test.quick_erc([ML, MW]) }
    let(:constraint_list) { erc1.constraint_list }
    let(:con1) { constraint_list[0] }
    let(:con2) { constraint_list[1] }
    before(:example) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each).and_yield(erc1)
      @rcd = Rcd.new(erc_list)
    end
    it 'is consistent' do
      expect(@rcd).to be_consistent
    end
    it 'has a list of all the constraints' do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it 'has the hierarchy [[con2],[con1]]' do
      expect(@rcd.hierarchy.to_a).to eq [[con2], [con1]]
    end
    it 'has ranked constraints [[con2],[con1]]' do
      expect(@rcd.ranked.to_a).to eq [[con2], [con1]]
    end
    it 'has no unranked constraints' do
      expect(@rcd.unranked).to be_empty
    end
    it 'has a list of the ERCs passed in' do
      # Rcd#erc_list returns an ErcList, convert to Array to compare.
      expect(@rcd.erc_list.to_ary).to eq [erc1]
    end
    it 'has explained ERCs [[erc1],[]]' do
      expect(@rcd.ex_ercs).to eq [[erc1], []]
    end
    it 'has no unexplained ercs' do
      expect(@rcd.unex_ercs).to be_empty
    end
  end

  context 'with ERC list [[ML,FW,MW],[MW,FL,Me]]' do
    let(:erc1) { Test.quick_erc([ML, FW, MW]) }
    let(:erc2) { Test.quick_erc([MW, FL, ME]) }
    let(:constraint_list) { erc1.constraint_list }
    let(:con1) { constraint_list[0] }
    let(:con2) { constraint_list[1] }
    let(:con3) { constraint_list[2] }
    before(:example) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each).and_yield(erc1).and_yield(erc2)
      @rcd = Rcd.new(erc_list)
    end
    it 'is consistent' do
      expect(@rcd.consistent?).to be true
    end
    it 'has a list of all the constraints' do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it 'has the hierarchy [[con3],[con1],[con2]]' do
      expect(@rcd.hierarchy.to_a).to eq [[con3], [con1], [con2]]
    end
    it 'has ranked constraints [[con3],[con1],[con2]]' do
      expect(@rcd.ranked.to_a).to eq [[con3], [con1], [con2]]
    end
    it 'has no unranked constraints' do
      expect(@rcd.unranked).to be_empty
    end
    it 'has a list of the ERCs passed in' do
      expect(@rcd.erc_list.to_ary).to eq [erc1, erc2]
    end
    it 'has explained ERCs [[erc1],[erc2],[]]' do
      expect(@rcd.ex_ercs).to eq [[erc1], [erc2], []]
    end
    it 'has no unexplained ercs' do
      expect(@rcd.unex_ercs).to be_empty
    end
  end

  context 'with ERC list [[MW,FE,ML],[ME,FL,MW],[ME,FW,ML]]' do
    let(:erc1) { Test.quick_erc([MW, FE, ML]) }
    let(:erc2) { Test.quick_erc([ME, FL, MW]) }
    let(:erc3) { Test.quick_erc([ME, FW, ML]) }
    let(:constraint_list) { erc1.constraint_list }
    let(:con1) { constraint_list[0] }
    let(:con2) { constraint_list[1] }
    let(:con3) { constraint_list[2] }
    before(:example) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each).and_yield(erc1).and_yield(erc2)\
                                       .and_yield(erc3)
      @rcd = Rcd.new(erc_list)
    end
    it 'is inconsistent' do
      expect(@rcd.consistent?).to be false
    end
    it 'has a list of all the constraints' do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it 'has the hierarchy [[con1],[con2,con3]]' do
      expect(@rcd.hierarchy.to_a).to eq [[con1], [con2, con3]]
    end
    it 'has ranked constraints [[con1]]' do
      expect(@rcd.ranked.to_a).to eq [[con1]]
    end
    it 'has unranked constraints [con2,con3]' do
      expect(@rcd.unranked).to eq [con2, con3]
    end
    it 'does not change the ranked constraints when calling #hierarchy()' do
      @rcd.hierarchy
      expect(@rcd.ranked).to eq [[con1]]
    end
    it 'has a list of the ERCs passed in' do
      expect(@rcd.erc_list.to_ary).to eq [erc1, erc2, erc3]
    end
    it 'has explained ERCs [[erc1]]' do
      expect(@rcd.ex_ercs).to eq [[erc1]]
    end
    it 'has unexplained ercs [erc2, erc3]' do
      expect(@rcd.unex_ercs).to eq [erc2, erc3]
    end
  end

  # ***********************
  # Specs for class methods
  # ***********************

  context 'Rcd.rankable?' do
    let(:con) { double('constraint') }
    let(:erc1) { double('erc1') }
    let(:erc2) { double('erc2') }
    context 'when the constraint prefers a loser' do
      before(:example) do
        allow(erc1).to receive(:l?).with(con).and_return(false)
        allow(erc2).to receive(:l?).with(con).and_return(true)
        @ercs = [erc1, erc2]
      end
      it 'returns false' do
        expect(Rcd.rankable?(con, @ercs)).to be false
      end
    end
    context 'when the constraint prefers no losers' do
      before(:example) do
        allow(erc1).to receive(:l?).with(con).and_return(false)
        allow(erc2).to receive(:l?).with(con).and_return(false)
        @ercs = [erc1, erc2]
      end
      it 'returns true' do
        expect(Rcd.rankable?(con, @ercs)).to be true
      end
    end
  end
  context 'Rcd.explained?' do
    let(:erc) { double('erc') }
    let(:con1) { double('con1') }
    let(:con2) { double('con2') }
    context 'when the erc is preferred by one of the constraints' do
      before(:example) do
        allow(erc).to receive(:w?).with(con1).and_return(false)
        allow(erc).to receive(:w?).with(con2).and_return(true)
        @constraints = [con1, con2]
      end
      it 'returns true' do
        expect(Rcd.explained?(erc, @constraints)).to be true
      end
    end
    context 'when the erc is not preferred by any of the constraints' do
      before(:example) do
        allow(erc).to receive(:w?).with(con1).and_return(false)
        allow(erc).to receive(:w?).with(con2).and_return(false)
        @constraints = [con1, con2]
      end
      it 'returns false' do
        expect(Rcd.explained?(erc, @constraints)).to be false
      end
    end
  end
  context 'Rcd.rank_next_stratum' do
    context 'with one newly ranked constraint' do
      let(:con_new_ranked) { double('constraint_newly_ranked') }
      let(:con_already_ranked) { double('constraint_already_ranked') }
      let(:con_unranked) { double('constraint_unranked') }
      before(:example) do
        stratum = [con_new_ranked]
        old_ranked = [[con_already_ranked]]
        old_unranked = [con_new_ranked, con_unranked]
        @ranked, @unranked =
          Rcd.rank_next_stratum(stratum, old_ranked, old_unranked)
      end
      it 'removes the constraint from unranked' do
        expect(@unranked.member?(con_new_ranked)).to be false
      end
      it 'adds the constraint as a new bottom stratum of ranked' do
        expect(@ranked[-1]).to eq [con_new_ranked]
      end
    end
    context 'with two newly ranked constraints' do
      let(:con_new_ranked1) { double('constraint_newly_ranked1') }
      let(:con_new_ranked2) { double('constraint_newly_ranked2') }
      let(:con_already_ranked) { double('constraint_already_ranked') }
      let(:con_unranked) { double('constraint_unranked') }
      before(:example) do
        stratum = [con_new_ranked1, con_new_ranked2]
        old_ranked = [[con_already_ranked]]
        old_unranked = [con_new_ranked1, con_unranked, con_new_ranked2]
        @ranked, @unranked =
          Rcd.rank_next_stratum(stratum, old_ranked, old_unranked)
      end
      it 'removes the first newly ranked constraint from unranked' do
        expect(@unranked.member?(con_new_ranked1)).to be false
      end
      it 'removes the second newly ranked constraint from unranked' do
        expect(@unranked.member?(con_new_ranked2)).to be false
      end
      it 'adds the constraints as a new bottom stratum of ranked' do
        expect(@ranked[-1]).to eq [con_new_ranked1, con_new_ranked2]
      end
    end
  end
  context 'Rcd.move_newly_explained_ercs' do
    context 'with one newly explained erc' do
      let(:erc_new_ex) { double('erc_newly_explained') }
      let(:erc_already_ex) { double('erc_already_explained') }
      let(:erc_unex) { double('erc_unexplained') }
      let(:con) { double('constraint') }
      before(:example) do
        allow(erc_new_ex).to receive(:w?).with(con).and_return(true)
        allow(erc_unex).to receive(:w?).with(con).and_return(false)
        stratum = [con]
        old_ex_ercs = [[erc_already_ex]]
        old_unex_ercs = [erc_new_ex, erc_unex]
        @ex_ercs, @unex_ercs =
          Rcd.move_newly_explained_ercs(stratum, old_ex_ercs, old_unex_ercs)
      end
      it 'removes the erc from unexplained' do
        expect(@unex_ercs.member?(erc_new_ex)).to be false
      end
      it 'adds the erc as a new bottom stratum of explained' do
        expect(@ex_ercs[-1]).to eq [erc_new_ex]
      end
    end
    context 'with two newly explained ercs'
  end
end

# Author: Bruce Tesar
#
# The specs for class Rcd make use of a test helper, Test.quick_erc.
# This helper, in turn, explicitly uses the following production classes:
# * Erc
# * Constraint

require_relative '../lib/rcd'
require_relative '../lib/erc_list'
require_relative '../test/helpers/quick_erc'

RSpec.describe Rcd do
  let(:erc_list){instance_double(ErcList, "ERC list")}
  before(:each) do
    stub_const 'ML', Test::ML
    stub_const 'ME', Test::ME
    stub_const 'MW', Test::MW
    stub_const 'FL', Test::FL
    stub_const 'FE', Test::FE
    stub_const 'FW', Test::FW
  end

  context "with an empty ERC list and 2 constraints" do
    let(:con1){"C1"}
    let(:con2){"C2"}
    let(:constraint_list){[con1,con2]}
    before(:each) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each)
      @rcd = Rcd.new(erc_list)
    end
    it "has the default label, RCD" do
      expect(@rcd.label).to eq "RCD"
    end
    it "is consistent" do
      expect(@rcd).to be_consistent
    end
    it "has a list of all the constraints" do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it "has a hierarchy with all constraints in the top stratum" do
      expect(@rcd.hierarchy).to eq [[con1,con2]]
    end
    it "has ranked constraints with all constraints in the top stratum" do
      expect(@rcd.ranked.to_a).to eq [[con1,con2]]
    end
    it "has no unranked constraints" do
      expect(@rcd.unranked).to be_empty
    end
    it "has an empty list of the ERCs passed in" do
      expect(@rcd.erc_list).to be_empty
    end
    it "returns an ErcList of ERCs passed in" do
      expect(@rcd.erc_list).to be_a_kind_of(ErcList)
    end
    it "has no explained ERCs" do
      expect(@rcd.ex_ercs).to eq [[]]
    end
    it "has no unexplained ercs" do
      expect(@rcd.unex_ercs).to be_empty
    end
  end

  context "Rcd with ERC list [[ML,MW]]" do
    let(:erc1){Test.quick_erc([ML,MW])}
    let(:constraint_list){erc1.constraint_list}
    let(:con1){constraint_list[0]}
    let(:con2){constraint_list[1]}
    before(:each) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each).and_yield(erc1)
      @rcd = Rcd.new(erc_list)
    end
    it "has the default label, RCD" do
      expect(@rcd.label).to eq "RCD"
    end
    it "is consistent" do
      expect(@rcd).to be_consistent
    end
    it "has a list of all the constraints" do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it "has the hierarchy [[con2],[con1]]" do
      expect(@rcd.hierarchy.to_a).to eq [[con2],[con1]]
    end
    it "has ranked constraints [[con2],[con1]]" do
      expect(@rcd.ranked.to_a).to eq [[con2],[con1]]
    end
    it "has no unranked constraints" do
      expect(@rcd.unranked).to be_empty
    end
    it "has a list of the ERCs passed in" do
      # Rcd#erc_list returns an ErcList, convert to Array to compare.
      expect(@rcd.erc_list.to_ary).to eq [erc1]
    end
    it "has explained ERCs [[erc1],[]]" do
      expect(@rcd.ex_ercs).to eq [[erc1],[]]
    end
    it "has no unexplained ercs" do
      expect(@rcd.unex_ercs).to be_empty
    end
    context "and specified label 'The label'" do
      before do
       @rcd = Rcd.new(erc_list, label: 'The Label')
      end
      it "returns the label 'The Label'" do
        expect(@rcd.label).to eq('The Label')
      end
    end
  end

  context "Rcd with ERC list [[ML,FW,MW],[MW,FL,Me]]" do
    let(:erc1){Test.quick_erc([ML,FW,MW])}
    let(:erc2){Test.quick_erc([MW,FL,ME])}
    let(:constraint_list){erc1.constraint_list}
    let(:con1){constraint_list[0]}
    let(:con2){constraint_list[1]}
    let(:con3){constraint_list[2]}
    before(:each) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each).and_yield(erc1).and_yield(erc2)
      @rcd = Rcd.new(erc_list)
    end
    it "is consistent" do
      expect(@rcd.consistent?).to be true
    end
    it "has a list of all the constraints" do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it "has the hierarchy [[con3],[con1],[con2]]" do
      expect(@rcd.hierarchy.to_a).to eq [[con3],[con1],[con2]]
    end
    it "has ranked constraints [[con3],[con1],[con2]]" do
      expect(@rcd.ranked.to_a).to eq [[con3],[con1],[con2]]
    end
    it "has no unranked constraints" do
      expect(@rcd.unranked).to be_empty
    end
    it "has a list of the ERCs passed in" do
      expect(@rcd.erc_list.to_ary).to eq [erc1, erc2]
    end
    it "has explained ERCs [[erc1],[erc2],[]]" do
      expect(@rcd.ex_ercs).to eq [[erc1],[erc2],[]]
    end
    it "has no unexplained ercs" do
      expect(@rcd.unex_ercs).to be_empty
    end
  end

  context "Rcd with ERC list [[MW,FE,ML],[ME,FL,MW],[ME,FW,ML]]" do
    let(:erc1){Test.quick_erc([MW,FE,ML])}
    let(:erc2){Test.quick_erc([ME,FL,MW])}
    let(:erc3){Test.quick_erc([ME,FW,ML])}
    let(:constraint_list){erc1.constraint_list}
    let(:con1){constraint_list[0]}
    let(:con2){constraint_list[1]}
    let(:con3){constraint_list[2]}
    before(:each) do
      allow(erc_list).to receive(:constraint_list).and_return(constraint_list)
      allow(erc_list).to receive(:each).and_yield(erc1).and_yield(erc2).
        and_yield(erc3)
      @rcd = Rcd.new(erc_list)
    end
    it "is inconsistent" do
      expect(@rcd.consistent?).to be false
    end
    it "has a list of all the constraints" do
      expect(@rcd.constraint_list).to eq constraint_list
    end
    it "has the hierarchy [[con1],[con2,con3]]" do
      expect(@rcd.hierarchy.to_a).to eq [[con1],[con2,con3]]
    end
    it "has ranked constraints [[con1]]" do
      expect(@rcd.ranked.to_a).to eq [[con1]]
    end
    it "has unranked constraints [con2,con3]" do
      expect(@rcd.unranked).to eq [con2,con3]
    end
    it "does not change the ranked constraints when calling #hierarchy()" do
      @rcd.hierarchy
      expect(@rcd.ranked).to eq [[con1]]
    end
    it "has a list of the ERCs passed in" do
      expect(@rcd.erc_list.to_ary).to eq [erc1,erc2,erc3]
    end
    it "has explained ERCs [[erc1]]" do
      expect(@rcd.ex_ercs).to eq [[erc1]]
    end
    it "has unexplained ercs [erc2, erc3]" do
      expect(@rcd.unex_ercs).to eq [erc2,erc3]
    end
  end

end # RSpec.describe Rcd

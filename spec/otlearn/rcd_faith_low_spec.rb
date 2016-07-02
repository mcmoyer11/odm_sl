# Author: Bruce Tesar

require 'otlearn/rcd_bias_low'
require_relative '../../test/helpers/quick_erc'
require 'comparative_tableau'

module Test
  RSpec.describe OTLearn::RcdFaithLow do
    RSpec.shared_examples "consistent scenarios" do
      it "has the same label as the CT" do
        expect(@rcd.label).to eq(@ct.label)
      end      
      it "returns consistent" do
        expect(@rcd.consistent?).to be true
      end
      it "has constraint list matching that of the first erc" do
        expect(@rcd.constraint_list).to eq(@erc1.constraint_list)
      end
      it "has no unranked constraints" do
        expect(@rcd.unranked.empty?).to be true
      end
      it "has no unexplained ercs" do
        expect(@rcd.unex_ercs.empty?).to be true
      end
    end
    context "RcdFaithLow with CT [[ML,FW,MW],[MW,FL,Me]]" do
      before(:each) do
        @erc1 = Test.quick_erc([ML,FW,MW])
        @erc2 = Test.quick_erc([MW,FL,ME])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1 << @erc2
        @rcd = OTLearn::RcdFaithLow.new(@ct)
      end
      include_examples "consistent scenarios"
      it "returns the forced total ranking [3:M3] [1:M1] [2:F2]" do
        expect(@rcd.hierarchy.to_s).to eq("[3:M3] [1:M1] [2:F2]")
      end
      it "has explained ERCs [[erc1],[erc2],[]]" do
        expect(@rcd.ex_ercs).to eq([[@erc1],[@erc2],[]])
      end
    end

    context "RcdFaithLow with CT [[ML,FW,MW]]" do
      before(:each) do
        @erc1 = Test.quick_erc([ML,FW,MW])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1
        @rcd = OTLearn::RcdFaithLow.new(@ct)
      end
      include_examples "consistent scenarios"
      it "ranks the markedness W constraint first, not the faithfulness W constraint" do
        expect(@rcd.hierarchy.to_s).to eq("[3:M3] [1:M1] [2:F2]")
      end
      it "has the single ERC explained by the top stratum" do
        expect(@rcd.ex_ercs).to eq([[@erc1],[],[]])
      end
    end
    
    context "RcdFaithLow with CT [[ME,FW,ML,FE]]" do
      before(:each) do
        @erc1 = Test.quick_erc([ME,FW,ML,FE])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1
        @rcd = OTLearn::RcdFaithLow.new(@ct)
      end
      include_examples "consistent scenarios"
      it "ranks non-L markedness constraints at the top, inactive F constraints at the bottom" do
        expect(@rcd.hierarchy.to_s).to eq("[1:M1] [2:F2] [3:M3] [4:F4]")
      end
      it "has the ERC explained by the second stratum" do
        expect(@rcd.ex_ercs).to eq([[],[@erc1],[],[]])
      end
    end

    context "RcdFaithLow with CT [[FE,FW,ML,FE],[FE,FE,ML,FW]]" do
      before(:each) do
        @erc1 = Test.quick_erc([FE,FW,ML,FE])
        @erc2 = Test.quick_erc([FE,FE,ML,FW])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1 << @erc2
        @rcd = OTLearn::RcdFaithLow.new(@ct)
      end
      include_examples "consistent scenarios"
      it "ranks only active F constraints to free a markedness constraint" do
        expect(@rcd.hierarchy.to_s).to eq("[2:F2 4:F4] [3:M3] [1:F1]")
      end
      it "has both ERCs explained by the top stratum" do
        expect(@rcd.ex_ercs).to eq([[@erc1,@erc2],[],[]])
      end
    end

    context "RcdFaithLow with CT [[FW,FW,ML,FE]]" do
      before(:each) do
        @erc1 = Test.quick_erc([FW,FW,ML,FE])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1
        @rcd = OTLearn::RcdFaithLow.new(@ct)
      end
      include_examples "consistent scenarios"
      it "when a single F constraint can free a markedness constraint, chooses the first one listed" do
        expect(@rcd.hierarchy.to_s).to eq("[1:F1] [3:M3] [2:F2 4:F4]")
      end
      it "has the ERC explained by the top stratum" do
        expect(@rcd.ex_ercs).to eq([[@erc1],[],[]])
      end
    end

    context "RcdFaithLow with CT [[FW,FW,ML,FE],[FE,FE,ML,FW]]" do
      before(:each) do
        @erc1 = Test.quick_erc([FW,FW,ML,FE])
        @erc2 = Test.quick_erc([FE,FE,ML,FW])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1 << @erc2
        @rcd = OTLearn::RcdFaithLow.new(@ct)
      end
      include_examples "consistent scenarios"
      it "when multiple F constraints are needed, ranks all active F constraints (instead of minimal number)" do
        expect(@rcd.hierarchy.to_s).to eq("[1:F1 2:F2 4:F4] [3:M3]")
      end
      it "has both ERCs explained by the top stratum" do
        expect(@rcd.ex_ercs).to eq([[@erc1,@erc2],[]])
      end
    end
  end # RSpec.describe Rcd_faith_low
end # module Test

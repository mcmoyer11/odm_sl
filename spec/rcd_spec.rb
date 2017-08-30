# Author: Bruce Tesar
#
# The specs for class Rcd make use of a test helper, Test.quick_erc.
# This helper, in turn, explicitly uses the following production classes:
# * Erc
# * Constraint
#
# These specs are placed in the module Test to give unqualified access
# to the constants associated with quick_erc(), without polluting the
# global namespace.

require 'rcd'
require_relative '../test/helpers/quick_erc'

module Test
  RSpec.describe Rcd do
    context "Rcd with ERC list [[ML,MW]]" do
      before(:each) do
        @erc1 = Test.quick_erc([ML,MW])
        @erc_list = instance_double(Erc_list, "ERC list")
        allow(@erc_list).to receive(:constraint_list).and_return(@erc1.constraint_list)
        allow(@erc_list).to receive(:each).and_yield(@erc1)
        @rcd = Rcd.new(@erc_list)
      end
      it "has the default label, RCD" do
        expect(@rcd.label).to eq("RCD")
      end
      it "returns consistent" do
        expect(@rcd.consistent?).to be true
      end
      it "has constraint list matching that of the first erc" do
        expect(@rcd.constraint_list).to eq(@erc1.constraint_list)
      end
      it "returns the hierarchy [2:M2] [1:M1]" do
        expect(@rcd.hierarchy.to_s).to eq("[2:M2] [1:M1]")
      end
      it "has no unranked constraints" do
        expect(@rcd.unranked.empty?).to be true
      end
      it "has explained ERCs [[erc1],[]]" do
        expect(@rcd.ex_ercs).to eq([[@erc1],[]])
      end
      it "has no unexplained ercs" do
        expect(@rcd.unex_ercs.empty?).to be true
      end
      context "and specified label 'The label'" do
        before do
         @rcd = Rcd.new(@erc_list, label: 'The Label')
        end
        it "returns the label 'The Label'" do
          expect(@rcd.label).to eq('The Label')
        end
      end
    end

    context "Rcd with ERC list [[ML,FW,MW],[MW,FL,Me]]" do
      before(:each) do
        @erc1 = Test.quick_erc([ML,FW,MW])
        @erc2 = Test.quick_erc([MW,FL,ME])
        @erc_list = instance_double(Erc_list, "ERC list")
        allow(@erc_list).to receive(:constraint_list).and_return(@erc1.constraint_list)
        allow(@erc_list).to receive(:each).and_yield(@erc1).and_yield(@erc2)
        @rcd = Rcd.new(@erc_list)
      end
      it "returns consistent" do
        expect(@rcd.consistent?).to be true
      end
      it "has constraint list matching that of the first erc" do
        expect(@rcd.constraint_list).to eq(@erc1.constraint_list)
      end
      it "returns the hierarchy [3:M3] [1:M1] [2:F2]" do
        expect(@rcd.hierarchy.to_s).to eq("[3:M3] [1:M1] [2:F2]")
      end
      it "has no unranked constraints" do
        expect(@rcd.unranked.empty?).to be true
      end
      it "has explained ERCs [[erc1],[erc2],[]]" do
        expect(@rcd.ex_ercs).to eq([[@erc1],[@erc2],[]])
      end
      it "has no unexplained ercs" do
        expect(@rcd.unex_ercs.empty?).to be true
      end
    end

    context "Rcd with ERC list [[MW,FE,ML],[ME,FL,MW],[ME,FW,ML]]" do
      before(:each) do
        @erc1 = Test.quick_erc([MW,FE,ML])
        @erc2 = Test.quick_erc([ME,FL,MW])
        @erc3 = Test.quick_erc([ME,FW,ML])
        @erc_list = instance_double(Erc_list, "ERC list")
        allow(@erc_list).to receive(:constraint_list).and_return(@erc1.constraint_list)
        allow(@erc_list).to receive(:each).and_yield(@erc1)
          .and_yield(@erc2).and_yield(@erc3)
        @rcd = Rcd.new(@erc_list)
      end
      it "returns inconsistent" do
        expect(@rcd.consistent?).to be false
      end
      it "returns the hierarchy [1:M1]" do
        expect(@rcd.hierarchy.to_s).to eq("[1:M1]")
      end
      it "has unranked constraints F2 and M3" do
        unranked_names = @rcd.unranked.map{|c| c.name}
        expect(unranked_names).to eq(["F2", "M3"])
      end
      it "has explained ERCs [[erc1]]" do
        expect(@rcd.ex_ercs).to eq([[@erc1]])
      end
      it "has unexplained ercs [erc2, erc3]" do
        expect(@rcd.unex_ercs).to eq([@erc2,@erc3])
      end
    end

  end # describe Rcd
end # module Test
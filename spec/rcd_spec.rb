# Author: Bruce Tesar
#
# Ordinarily, one should test classes in isolation as much as possible,
# so that the contents of one class don't cause failure of any specs for
# another class. However, some of the learning methods are sufficiently
# interwoven with other classes that it seems unproductive on balance
# to completely duplicate a complex collection of interrelated classes
# with test dummies. That is the case here.
# 
# The specs for Rcd make direct use of these production classes:
# * Comparative_tableau
#
# The specs for class Rcd also make use of some test helpers, Test.quick_erc
# and some relate constants. These helpers, in turn, explicitly use
# the following production classes:
# * Erc
# * Constraint
#
# These specs are placed in the module Test to give unqualified access
# to the constants associated with quick_erc(), without polluting the
# global namespace.

require 'rcd'
require_relative '../test/helpers/quick_erc'
require 'comparative_tableau'

module Test
  RSpec.describe Rcd do
    context "Rcd with CT [[ML,MW]]" do
      before(:each) do
        @erc1 = Test.quick_erc([ML,MW])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1
        @rcd = Rcd.new(@ct)
      end
      it "has the same label as the CT" do
        expect(@rcd.label).to eq(@ct.label)
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
    end

    context "Rcd with CT [[ML,FW,MW],[MW,FL,Me]]" do
      before(:each) do
        @erc1 = Test.quick_erc([ML,FW,MW])
        @erc2 = Test.quick_erc([MW,FL,ME])
        @ct = Comparative_tableau.new("CT consistent")
        @ct << @erc1 << @erc2
        @rcd = Rcd.new(@ct)
      end
      it "has the same label as the CT" do
        expect(@rcd.label).to eq(@ct.label)
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

    context "Rcd with CT [[MW,FE,ML],[ME,FL,MW],[ME,FW,ML]]" do
      before(:each) do
        @erc1 = Test.quick_erc([MW,FE,ML])
        @erc2 = Test.quick_erc([ME,FL,MW])
        @erc3 = Test.quick_erc([ME,FW,ML])
        @ct = Comparative_tableau.new("CT inconsistent")
        @ct << @erc1 << @erc2 << @erc3
        @rcd = Rcd.new(@ct)
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
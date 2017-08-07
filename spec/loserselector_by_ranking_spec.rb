# Author: Bruce Tesar

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'loserselector_by_ranking'

RSpec.describe LoserSelector_by_ranking do
  before(:each) do
    @winner = instance_double(Candidate, "winner")
    @input = "input"
    # Mock: retrieve the input of the winner
    expect(@winner).to receive(:input).and_return(@input)
    @loser = instance_double(Candidate, "loser")
    @sys = double("system")
    @erc_list = double("erc list")
    competition = instance_double(Competition, "competition")
    # Mock: compute the competition for the input
    expect(@sys).to receive(:gen).with(@input).and_return(competition)
    @rcd_class = double("rcd class")
    rcd_object = double("rcd object")
    # Mock: construct an Rcd object
    expect(@rcd_class).to receive(:new).with(@erc_list).and_return(rcd_object)
    hierarchy = instance_double(Hierarchy, "hierarchy")
    # Mock: construct a constraint hierarchy
    expect(rcd_object).to receive(:hierarchy).and_return(hierarchy)
    @optimizer = class_double(MostHarmonic, "optimizer class")
    @mh = instance_double(MostHarmonic,"optimizer object")
    # Mock: compute the optimal candidates
    expect(@optimizer).to receive(:new).with(competition,hierarchy).and_return(@mh)
  end
  context "given a winner that is the sole optimum" do
    before(:each) do
      # NOTE: this is NOT testing the logic of the block given to mh.find
      allow(@mh).to receive(:find).and_return(nil)
      @select_loser_by_ranking = LoserSelector_by_ranking.new(@sys, rcd_class: @rcd_class, optimizer_class: @optimizer)
    end
    it "returns nil" do
      expect(@select_loser_by_ranking.select_loser(@winner,@erc_list)).to be nil
    end
  end

  context "given a winner that is not the sole optimum"
  
  context "given a winner not contained in the set of optima"
end


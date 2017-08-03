# Author: Bruce Tesar

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'loserselector_by_ranking'

RSpec.describe LoserSelector_by_ranking do
  before(:each) do
    @winner = instance_double(Candidate, "winner")
    @input = "input"
    allow(@winner).to receive(:input).and_return(@input)
    @loser = instance_double(Candidate, "loser")
    @sys = double("system")
    @hypothesis = instance_double(Hypothesis, "hypothesis")
    @erc_list = double("erc list")
  end
  context "given a winner that is the sole optimum" do
    before(:each) do
      competition = instance_double(Competition)
      optima_list = [@winner]
      allow(@sys).to receive(:gen).with(@input).and_return(optima_list)
      allow(@hypothesis).to receive(:erc_list).and_return(@erc_list)
      rcd_class = double("rcd class")
      rcd_object = double("rcd object")
      allow(rcd_class).to receive(:new).with(@erc_list).and_return(rcd_object)
      hierarchy = instance_double(Hierarchy)
      allow(rcd_object).to receive(:hierarchy).and_return(hierarchy)
      @select_loser_by_ranking = LoserSelector_by_ranking.new(@sys,rcd_class)
      optimizer = class_double(MostHarmonic, "optimizer")
      @select_loser_by_ranking = LoserSelector_by_ranking.new(@sys,rcd_class)      
#      @select_loser_by_ranking.set_optimizer(optimizer)
    end

    it "computes the constraint hierarchy"
    it "computes the competition for the input"
    it "finds the optimal candidates"
    it "returns nil" do
      pending
      expect(@select_loser_by_ranking.select_loser(@winner,@hypothesis.erc_list)).to be nil
    end
  end

  context "given a winner that is not the sole optimum" do
    before(:each) do
      optima_list = [@loser]
      allow(@sys).to receive(:gen).with(@input).and_return(optima_list)
      allow(@hypothesis).to receive(:erc_list).and_return(@erc_list)
      rcd_class = double("rcd class")
      rcd_object = double("rcd object")
      allow(rcd_class).to receive(:new).with(@erc_list).and_return(rcd_object)
      allow(rcd_object).to receive(:hierarchy)
      optimizer = class_double(MostHarmonic, "optimizer")
      @select_loser_by_ranking = LoserSelector_by_ranking.new(@sys,rcd_class)      
#      @select_loser_by_ranking.set_optimizer(optimizer)
    end
    it "computes the ranking"
    it "finds the optimal candidates"
    it "returns the sole optimum" do
      pending
      expect(@select_loser_by_ranking.select_loser(@winner,@hypothesis.erc_list)).to eq @loser
    end
  end
  
  context "given a winner not contained in the set of optima" do
    it "computes the ranking"
    it "finds the optimal candidates"
    it "returns one of the optima"
  end
end


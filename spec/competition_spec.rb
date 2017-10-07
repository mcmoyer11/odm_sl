# Author: Bruce Tesar

require 'competition'

RSpec.describe Competition do
  before(:example) do
    @wl_pair_class = double("mock WL pair class")
    @erc_list_class = double("mock erc list class")
    @erc_list = instance_double(Erc_list, "erc list")
    allow(@erc_list_class).to receive(:new).and_return(@erc_list)
  end
  
  def construct_candidate(name, input, opt)
    candidate = instance_double(Candidate, name)
    allow(candidate).to receive(:input).and_return(input)
    allow(candidate).to receive(:opt?).and_return(opt)
    return candidate
  end
      
  context "with one winner and one loser" do
    before(:each) do
      @winner = construct_candidate("Winner", "INPUT", true)
      @loser = construct_candidate("Loser", "INPUT", false)
      @pair1 = instance_double(Win_lose_pair, "pair 1")
      allow(@wl_pair_class).to receive(:new).with(@winner,@loser).and_return(@pair1)
      allow(@erc_list).to receive(:add).with(@pair1)
      @competition = Competition.new(wl_pair_class: @wl_pair_class, erc_list_class: @erc_list_class)
      @competition << @winner
      @competition << @loser
    end

    it "returns a constructed erc_list" do
      pair_list = @competition.winner_loser_pairs
      expect(pair_list).to eq(@erc_list)
    end
    it "adds a WL pair with winner and loser" do
      pair_list = @competition.winner_loser_pairs
      expect(@wl_pair_class).to have_received(:new).with(@winner,@loser)
    end
    it "adds 1 winner-loser pair" do
      pair_list = @competition.winner_loser_pairs
      expect(@erc_list).to have_received(:add).exactly(1).times
    end
  end
  
  context "with one winner and two losers" do
    before(:each) do
      @winner = construct_candidate("Winner", "INPUT", true)
      @loser1 = construct_candidate("Loser1", "INPUT", false)
      @loser2 = construct_candidate("Loser2", "INPUT", false)
      @pair1 = instance_double(Win_lose_pair, "pair 1")
      @pair2 = instance_double(Win_lose_pair, "pair 2")
      allow(@wl_pair_class).to receive(:new).with(@winner,@loser1).and_return(@pair1)
      allow(@wl_pair_class).to receive(:new).with(@winner,@loser2).and_return(@pair2)
      allow(@erc_list).to receive(:add).with(@pair1)
      allow(@erc_list).to receive(:add).with(@pair2)
      @competition = Competition.new(wl_pair_class: @wl_pair_class, erc_list_class: @erc_list_class)
      @competition << @winner
      @competition << @loser1
      @competition << @loser2
    end

    it "returns a constructed erc_list" do
      pair_list = @competition.winner_loser_pairs
      expect(pair_list).to eq(@erc_list)
    end
    it "adds a WL pair with winner and loser1" do
      pair_list = @competition.winner_loser_pairs
      expect(@wl_pair_class).to have_received(:new).with(@winner,@loser1)
    end
    it "adds a WL pair with winner and loser2" do
      pair_list = @competition.winner_loser_pairs
      expect(@wl_pair_class).to have_received(:new).with(@winner,@loser2)
    end
    it "adds 2 winner-loser pairs" do
      pair_list = @competition.winner_loser_pairs
      expect(@erc_list).to have_received(:add).exactly(2).times
    end
  end
  
  context "no winner" do
    before(:example) do
      @loser1 = construct_candidate("Loser1", "INPUT", false)
      @loser2 = construct_candidate("Loser2", "INPUT", false)      
      @competition = Competition.new(wl_pair_class: @wl_pair_class, erc_list_class: @erc_list_class)
      @competition << @loser1
      @competition << @loser2
    end
    it "raises an error indicating no winner" do
      expect{@competition.winner_loser_pairs}.to raise_error(RuntimeError)
    end
  end

end # describe Competition

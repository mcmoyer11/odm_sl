# Author: Bruce Tesar

require_relative '../lib/loser_selector_exhaustive'
require_relative '../lib/sl/system'
require_relative '../lib/word'
require_relative '../lib/erc_list'

RSpec.describe LoserSelectorExhaustive do
  let(:input){instance_double(Input, "Input")}
  let(:winner){double("Winner")}
  let(:cand1){double("Cand1")}
  let(:ident_viols){double("Ident_viols")}
  let(:uninformative){double("uninformative")}
  let(:competition){[]}
  let(:sys){instance_double(SL::System, "system")}
  # Dependency Injections (and related)
  let(:erc_list_class){double('erc_list_class')}
  let(:erc_list){instance_double(ErcList, 'erc_list')}
  let(:win_lose_pair_class){double('win_lose_pair_class')}
  let(:wl_pair){instance_double(Win_lose_pair, 'wl_pair')}
  before(:example) do
    allow(sys).to receive(:gen).with(input).and_return(competition)
    allow(erc_list_class).to receive(:new).and_return(erc_list)
    allow(win_lose_pair_class).to receive(:new).and_return(wl_pair)
    allow(erc_list).to receive(:add_all).and_return(erc_list)
    allow(erc_list).to receive(:add)
    allow(winner).to receive(:input).and_return(input)
    allow(winner).to receive(:ident_viols?).with(winner).and_return(true)
    allow(cand1).to receive(:ident_viols?).with(winner).and_return(false)
    allow(ident_viols).to receive(:ident_viols?).with(winner).and_return(true)
    allow(uninformative).to receive(:ident_viols?).with(winner).and_return(false)
    @selector = LoserSelectorExhaustive.new(sys,
      erc_list_class: erc_list_class, win_lose_pair_class: win_lose_pair_class)
  end
  
  context "given an empty ERC list" do
    let(:param_ercs){[]}
    context "and a competition where the winner is not first" do
      before(:example) do
        competition << cand1 << winner
        allow(erc_list).to receive(:consistent?).and_return(true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the first candidate in the list" do
        expect(@loser).to eq(competition[0])
      end
    end

    context "and a competition where the winner is first" do
      before(:example) do
        competition << winner << cand1
        allow(erc_list).to receive(:consistent?).and_return(true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the second candidate in the list" do
        expect(@loser).to eq(competition[1])
      end
    end

    context "and a competition where the first candidate has identical violations" do
      before(:example) do
        competition << ident_viols << cand1 << winner
        allow(erc_list).to receive(:consistent?).and_return(true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the second candidate" do
        expect(@loser).to eq(competition[1])
      end
    end

    context "and a competition where the first candidate has identical violations and the second is the winner" do
      before(:example) do
        competition << ident_viols << winner << cand1
        allow(erc_list).to receive(:consistent?).and_return(true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the third candidate" do
        expect(@loser).to eq(competition[2])
      end
    end

    context "and a competition where the winner is the only candidate" do
      before(:example) do
        competition << winner
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns nil" do
        expect(@loser).to be_nil
      end
    end
    
    context "and a competition where an uniformative candidate precedes an informative one" do
      before(:example) do
        competition << uninformative << cand1 << winner
        allow(erc_list).to receive(:consistent?).and_return(false, true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the second candidate" do
        expect(@loser).to eq(competition[1])
      end
    end
  end

  context "given an ERC list with one external erc" do
    let(:extern_erc){double('extern_erc')}
    let(:param_ercs){[extern_erc]}
    before(:example) do
      allow(extern_erc).to receive(:ident_viols?).with(winner).and_return(false)
    end
    context "and a competition ordered uninformative, winner, cand1, ident_viols" do
      before(:example) do
        competition << uninformative << winner << cand1 << ident_viols
        allow(erc_list).to receive(:consistent?).and_return(false, true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns cand1" do
        expect(@loser).to eq(competition[2])
      end
      it "adds the external erc to erc_list" do
        expect(erc_list).to have_received(:add_all).with([extern_erc]).at_least(1).times
      end
    end
  end

end # RSpec.describe LoserSelectorExhaustive

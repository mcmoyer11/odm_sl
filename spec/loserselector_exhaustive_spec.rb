# Author: Bruce Tesar

require 'loserselector_exhaustive'
require 'sl/system'
require 'word'
require 'erc_list'

RSpec.describe LoserSelector_exhaustive, :wip do
  # Returns an instance double for a word
  def test_word(input, label)
    word = instance_double(Word, label)
    allow(word).to receive(:input).and_return(input)
    return word
  end
  
  let(:input){instance_double(Input, "Input")}
  let(:winner){test_word(input, "Winner")}
  let(:cand1){test_word(input, "Cand1")}
  let(:ident_viols){test_word(input, "Ident_viols")}
  let(:competition){[]}
  let(:sys){instance_double(SL::System, "system")}
  # Dependency Injections (and related)
  let(:erc_list_class){double('erc_list_class')}
  let(:erc_list){instance_double(Erc_list, 'erc_list')}
  let(:erc_list_dup){instance_double(Erc_list, 'erc_list_dup')}
  let(:win_lose_pair_class){double('win_lose_pair_class')}
  let(:wl_pair){instance_double(Win_lose_pair, 'wl_pair')}
  before(:example) do
    allow(sys).to receive(:gen).with(input).and_return(competition)
    allow(erc_list_class).to receive(:new).and_return(erc_list)
    allow(win_lose_pair_class).to receive(:new).and_return(wl_pair)
    allow(erc_list).to receive(:add)
    allow(erc_list).to receive(:dup).and_return(erc_list_dup)
    allow(erc_list_dup).to receive(:add)
    allow(winner).to receive(:ident_viols?).with(winner).and_return(true)
    allow(cand1).to receive(:ident_viols?).with(winner).and_return(false)
    allow(ident_viols).to receive(:ident_viols?).with(winner).and_return(true)
    @selector = LoserSelector_exhaustive.new(sys,
      erc_list_class: erc_list_class, win_lose_pair_class: win_lose_pair_class)
  end
  
  context "given an empty ERC list" do
    let(:param_ercs){[]}
    context "and a competition where the winner is not first" do
      before(:example) do
        competition << cand1 << winner
        allow(erc_list_dup).to receive(:consistent?).and_return(true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the first candidate in the list" do
        expect(@loser).to eq(competition[0])
      end
    end

    context "and a competition where the winner is first" do
      before(:example) do
        competition << winner << cand1
        allow(erc_list_dup).to receive(:consistent?).and_return(true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the second candidate in the list" do
        expect(@loser).to eq(competition[1])
      end
    end

    context "and a competition where the first candidate has identical violations" do
      before(:example) do
        competition << ident_viols << cand1 << winner
        allow(erc_list_dup).to receive(:consistent?).and_return(true)
        @loser = @selector.select_loser(winner, param_ercs)
      end
      it "returns the second candidate" do
        expect(@loser).to eq(competition[1])
      end
    end

    context "and a competition where the first candidate has identical violations and the second is the winner" do
      before(:example) do
        competition << ident_viols << winner << cand1
        allow(erc_list_dup).to receive(:consistent?).and_return(true)
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
  end

end # RSpec.describe LoserSelector_exhaustive

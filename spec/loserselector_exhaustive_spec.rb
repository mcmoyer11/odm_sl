# Author: Bruce Tesar

require 'loserselector_exhaustive'
require 'sl/system'

RSpec.describe LoserSelector_exhaustive do
  # Returns an instance double for a word
  def test_word(input, label, constraint_list)
    word = instance_double(Word, label)
    allow(word).to receive(:input).and_return(input)
    allow(word).to receive(:constraint_list).and_return(constraint_list)
    return word
  end
  
  before(:example) do
    @con1 = instance_double(Constraint, "Constraint1")
    @con2 = instance_double(Constraint, "Constraint2")
    @con2 = instance_double(Constraint, "Constraint3")
    @constraint_list = [@con1, @con2, @con3]
    @input = instance_double(Input, "Input")
    @competition = []
    @sys = instance_double(SL::System, "system")
    allow(@sys).to receive(:gen).with(@input).and_return(@competition)
    #
    @winner = test_word(@input, "Winner", @constraint_list)
    allow(@winner).to receive(:ident_viols?).with(@winner).and_return(true)
    allow(@winner).to receive(:get_viols).with(@con1).and_return(1)
    allow(@winner).to receive(:get_viols).with(@con2).and_return(2)
    allow(@winner).to receive(:get_viols).with(@con3).and_return(1)
    @cand1 = test_word(@input, "Cand1", @constraint_list)
    allow(@cand1).to receive(:ident_viols?).with(@winner).and_return(false)
    allow(@cand1).to receive(:get_viols).with(@con1).and_return(2)
    allow(@cand1).to receive(:get_viols).with(@con2).and_return(1)
    allow(@cand1).to receive(:get_viols).with(@con3).and_return(1)
    #
    @selector = LoserSelector_exhaustive.new(@sys)
  end
  context "given an empty ERC list" do
    before(:example) do
      @erc_list = []
    end
    context "and a competition where the winner is not first" do
      before(:example) do
        @competition << @cand1 << @winner
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns the first candidate in the list" do
        expect(@loser).to eq(@competition[0])
      end
    end
    context "and a competition where the winner is first" do
      before(:example) do
        @competition << @winner << @cand1
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns the second candidate in the list" do
        expect(@loser).to eq(@competition[1])
      end
    end
    context "and a competition where the first candidate has identical violations" do
      before(:example) do
        @ident_viols = test_word(@input, "Ident_viols", @constraint_list)
        allow(@ident_viols).to receive(:ident_viols?).with(@winner).and_return(true)
        @competition << @ident_viols << @cand1 << @winner
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns the second candidate" do
        expect(@loser).to eq(@competition[1])
      end
    end
    context "and a competition where the first candidate has identical violations and the second is the winner" do
      before(:example) do
        @ident_viols = test_word(@input, "Ident_viols", @constraint_list)
        allow(@ident_viols).to receive(:ident_viols?).with(@winner).and_return(true)
        @competition << @ident_viols << @winner << @cand1
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns the third candidate" do
        expect(@loser).to eq(@competition[2])
      end
    end
    context "and a competition where the winner is the only candidate" do
      before(:example) do
        @competition << @winner
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns nil" do
        expect(@loser).to be_nil
      end
    end
  end

  context "given an ERC list with [W L e]" do
    before(:example) do
      @erc1 = instance_double(Erc)
      allow(@erc1).to receive(:constraint_list).and_return(@constraint_list)
      allow(@erc1).to receive(:l?).with(@con1).and_return(false)
      allow(@erc1).to receive(:l?).with(@con2).and_return(true)
      allow(@erc1).to receive(:l?).with(@con3).and_return(false)
      allow(@erc1).to receive(:w?).with(@con1).and_return(true)
      allow(@erc1).to receive(:w?).with(@con2).and_return(false)
      allow(@erc1).to receive(:w?).with(@con3).and_return(false)
      @erc_list = [@erc1]
      # Define a candidate that is informative relative to erc1
      # winner ~ informative is [e W L]
      @informative = test_word(@input, "Informative Candidate", @constraint_list)
      allow(@informative).to receive(:ident_viols?).with(@winner).and_return(false)
      allow(@informative).to receive(:get_viols).with(@con1).and_return(1)
      allow(@informative).to receive(:get_viols).with(@con2).and_return(3)
      allow(@informative).to receive(:get_viols).with(@con3).and_return(0)
      # Define a candidate that is redundant relative to erc1
      # winner ~ redundant is [W L e]
      @redundant = test_word(@input, "Redundant Candidate", @constraint_list)
      allow(@redundant).to receive(:ident_viols?).with(@winner).and_return(false)
      allow(@redundant).to receive(:get_viols).with(@con1).and_return(2)
      allow(@redundant).to receive(:get_viols).with(@con2).and_return(1)
      allow(@redundant).to receive(:get_viols).with(@con3).and_return(1)
    end
    context "and an informative first candidate" do
      before(:example) do
        @competition << @informative << @redundant << @winner
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns the first candidate" do
        expect(@loser).to eq(@competition[0])
      end
    end
    context "and a redundant first candidate followed by the winner" do
      before(:example) do
        @competition << @redundant << @winner << @informative
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns the third candidate" do
        expect(@loser).to eq(@competition[2])
      end
    end
    context "and a first candidate whose losing to the winner would be inconsistent with the ERC list" do
      before(:example) do
        # winner ~ inconsistent is [L W e]
        # Because this is inconsistent with the ERC list, it is not redundant,
        # and the loser should therefore be considered informative (it will
        # yield inconsistency when added to the ERC list, which is indeed informative)
        @inconsistent = test_word(@input, "Inconsistent Candidate", @constraint_list)
        allow(@inconsistent).to receive(:ident_viols?).with(@winner).and_return(false)
        allow(@inconsistent).to receive(:get_viols).with(@con1).and_return(0)
        allow(@inconsistent).to receive(:get_viols).with(@con2).and_return(3)
        allow(@inconsistent).to receive(:get_viols).with(@con3).and_return(1)
        @competition << @inconsistent << @redundant << @winner
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns the first candidate" do
        expect(@loser).to eq(@competition[0])
      end
    end
    context "and only redundant candidates" do
      before(:example) do
        @competition << @redundant << @winner
        @loser = @selector.select_loser(@winner, @erc_list)
      end
      it "returns nil" do
        expect(@loser).to be_nil
      end
    end
  end
end # RSpec.describe LoserSelector_exhaustive


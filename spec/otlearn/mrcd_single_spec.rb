# Author: Bruce Tesar

require_relative '../../lib/otlearn/mrcd_single'

RSpec.describe OTLearn::MrcdSingle, :wip do
  let(:winner){double('winner')}
  let(:morphword){double('morphword')}
  before(:each) do
    allow(winner).to receive(:morphword).and_return(morphword)
    allow(morphword).to receive(:to_s).and_return("morphword_name")
  end
  
  context "with a word that is already optimal" do
    before(:each) do
      # allow().to
      # @mrcd_single = OTLearn::MrcdSingle.new(winner, grammar, selector)
    end
    it "duplicates the parameter grammar"
    it "creates no added pairs"
    it "has a grammar that is consistent"
    it "calls selector once"
  end
  
  context "with a word requiring one pair" do
    before(:each) do
      # allow().to
      # @mrcd_single = OTLearn::MrcdSingle.new(winner, grammar, selector)
    end
    it "creates one added pair"
    it "creates a pair with the winner and the first loser"
    it "has a grammar that is consistent"
    it "calls selector twice"
  end
  
  context "with a word requiring two pairs" do
    before(:each) do
      # allow().to
      # @mrcd_single = OTLearn::MrcdSingle.new(winner, grammar, selector)
    end
    it "creates two added pairs"
    it "creates a pair with the winner and the first loser"
    it "creates a pair with the winner and the second loser"
    it "has a grammar that is consistent"
    it "calls selector three times"
  end
  
  context "with a word reaching inconsistency after one pair" do
    before(:each) do
      # allow().to
      # @mrcd_single = OTLearn::MrcdSingle.new(winner, grammar, selector)
    end
    it "creates one added pair"
    it "creates a pair with the winner and the first loser"
    it "has a grammar that is inconsistent"
    it "calls selector twice"
  end
  
end # RSpec.describe MrcdSingle

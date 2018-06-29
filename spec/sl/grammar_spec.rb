# Author: Bruce Tesar

require 'sl/grammar'

RSpec.describe SL::Grammar do
  context "A new SL::Grammar, with no parameters," do
    before(:each) do
      @grammar = SL::Grammar.new
      @morph = double("Morpheme")
    end
    it "returns a reference to SL::SYSTEM" do
      expect(@grammar.system).to eq(SL::SYSTEM)
    end
    it "returns an empty ERC list" do
      expect(@grammar.erc_list).to be_empty
    end
    it "returns an empty lexicon" do
      expect(@grammar.lexicon.size).to eq(0)
    end
    it "returns the label SL::Grammar" do
      expect(@grammar.label).to eq "SL::Grammar"
    end
    it "returns nil when a lexical entry is requested" do
      expect(@grammar.get_uf(@morph)).to eq(nil)
    end
  end
  
  context "A new grammar, when given a lexicon," do
    before(:each) do
      @lex = instance_double(Lexicon)
      allow(@lex).to receive(:get_uf).with("the_morph").and_return("the_uf")
      @grammar = SL::Grammar.new(lexicon: @lex)
    end
    it "returns the given lexicon" do
      expect(@grammar.lexicon).to eq(@lex)
    end
    it 'returns uf "the_uf" for the morpheme "the_morph"' do
      expect(@grammar.get_uf("the_morph")).to eq("the_uf")
    end
  end
  
  context "A grammar" do
    before(:each) do
      @gram = SL::Grammar.new
    end
    context "when duplicated with dup" do
      before(:each) do
        @dup = @gram.dup
      end
      it "should have distinct objects for the ERC list" do
        expect(@gram.erc_list).not_to equal(@dup.erc_list)
      end
      it "should have distinct objects for lexicon" do
        expect(@gram.lexicon).not_to equal(@dup.lexicon)
      end
    end
    context "when duplicated with dup_same_lexicon" do
      before(:each) do
        @dup = @gram.dup_same_lexicon
      end
      it "should have distinct objects for the ERC list" do
        expect(@gram.erc_list).not_to equal(@dup.erc_list)
      end
      it "should have the same object for lexicon" do
        expect(@gram.lexicon).to equal(@dup.lexicon)
      end
    end
  end
end # describe SL::Grammar

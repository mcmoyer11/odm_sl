# Author: Bruce Tesar

require 'sl/grammar'

RSpec.describe SL::Grammar do
  context "A new Grammar with no constructor parameters" do
    before(:each) do
      @grammar = SL::Grammar.new
      @morph = double("Morpheme")
    end
    it "returns a reference to SYSTEM" do
      expect(@grammar.system).to eq(SL::SYSTEM)
    end
    it "returns an empty lexicon" do
      expect(@grammar.lexicon.size).to eq(0)
    end
    it "returns nil when a lexical entry is requested" do
      expect(@grammar.get_uf(@morph)).to eq(nil)
    end
  end
  
  context "A new grammar constructed with parameters" do
    before(:each) do
      @hier = double("Hierarchy")
      @morph = "the_morph"
      @lex_entry = double("Lexical_Entry")
      allow(@lex_entry).to receive(:uf).and_return("the_uf")
      allow(@lex_entry).to receive(:morpheme).and_return("the_morph")
      # The lexicon has the basic interface of Array, so use an Array to mock it.
      @lex = [@lex_entry]
      @grammar = SL::Grammar.new(@hier, @lex)
    end
    it "returns the given lexicon" do
      expect(@grammar.lexicon).to eq(@lex)
    end
    it 'returns uf "the_uf" for the morpheme "the_morph"' do
      expect(@grammar.get_uf(@morph)).to eq("the_uf")
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
      it "should have distinct objects for lexicon" do
        expect(@gram.lexicon).not_to equal(@dup.lexicon)
      end
    end
    context "when duplicated with dup_hier_only" do
      before(:each) do
        @dup = @gram.dup_hier_only
      end
      it "should have the same object for lexicon" do
        expect(@gram.lexicon).to equal(@dup.lexicon)
      end
    end
  end
end # describe SL::Grammar

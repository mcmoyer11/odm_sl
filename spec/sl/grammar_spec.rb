# Author: Bruce Tesar

require_relative '../../lib/sl/grammar'

RSpec.describe SL::Grammar do
  context "A new SL::Grammar, with no parameters," do
    let(:morph){double('morph')}
    before(:example) do
      @grammar = SL::Grammar.new
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
      expect(@grammar.get_uf(morph)).to eq(nil)
    end
  end
  
  context "A new grammar, when given a lexicon," do
    let(:lex){instance_double(Lexicon)}
    before(:example) do
      allow(lex).to receive(:get_uf).with("the_morph").and_return("the_uf")
      @grammar = SL::Grammar.new(lexicon: lex)
    end
    it "returns the given lexicon" do
      expect(@grammar.lexicon).to eq(lex)
    end
    it 'returns uf "the_uf" for the morpheme "the_morph"' do
      expect(@grammar.get_uf("the_morph")).to eq("the_uf")
    end
  end
  
  context "A grammar" do
    before(:example) do
      @gram = SL::Grammar.new
    end
    context "when duplicated with dup" do
      before(:example) do
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
      before(:example) do
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
  
  context "when parse_output is called" do
    let(:erc_list){double('erc_list')}
    let(:lexicon){double('lexicon')}
    let(:system){double('system')}
    let(:output){double('output')}
    let(:word){double('word')}
    before(:example) do
      allow(system).to receive(:parse_output).with(output,lexicon).
        and_return(word)
      @grammar = SL::Grammar.new(erc_list: erc_list, lexicon: lexicon,
        system: system)
      @return_value = @grammar.parse_output(output)
    end
    it "calls system.parse_output" do
      expect(system).to have_received(:parse_output)
    end
    it "returns the full word" do
      expect(@return_value).to eq word
    end
  end
end # describe SL::Grammar

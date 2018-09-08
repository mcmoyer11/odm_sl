# Author: Bruce Tesar

require_relative '../lib/lexicon'
require_relative '../lib/lexical_entry'

RSpec.describe Lexicon do
  context "with an entry for morpheme M1" do
    before(:each) do
      @m1 = instance_double(Lexical_Entry)
      allow(@m1).to receive(:morpheme).and_return("M1")
      allow(@m1).to receive(:uf).and_return("uf_for_M1")
      @lexicon = Lexicon.new
      @lexicon.add(@m1)
    end
    it "returns the uf for M1" do
      expect(@lexicon.get_uf("M1")).to eq("uf_for_M1")
    end
  end

  context "with no entry for morpheme M1" do
    before(:each) do
      @lexicon = Lexicon.new
    end
    it "returns nil for the uf for M1" do
      expect(@lexicon.get_uf("M1")).to be_nil
    end
  end
end # RSpec.describe Lexicon

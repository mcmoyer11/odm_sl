# Author: Bruce Tesar

require 'hypothesis'
require 'erc'

RSpec.describe "A hypothesis" do
  before(:each) do
    @grammar = double(SL::Grammar)
    @system = double(SL::System)
    @constraint_list = ["C1","C2"]
    allow(@system).to receive(:constraints).and_return(@constraint_list)
    allow(@grammar).to receive(:system).and_return(@system)
    @hypothesis = Hypothesis.new(@grammar)
  end
  context "with no ercs" do
    it "is consistent" do
      expect(@hypothesis.consistent?).to be true
    end
    it "returns an empty list of ercs" do
      expect(@hypothesis.erc_list.empty?).to be true
    end
    it "returns a reference to the linguistic system" do
      expect(@hypothesis.system).to equal @system
    end
  end
  context "with one erc" do
    before do
      @erc1 = Erc.new(@constraint_list)
      @erc1.set_w(@constraint_list[0])
      @erc1.set_l(@constraint_list[1])
      @add_erc1_return_value = @hypothesis.add_erc(@erc1)
    end
    it "had add_erc() return true" do
      expect(@add_erc1_return_value).to be true
    end
    it "is consistent" do
      expect(@hypothesis.consistent?).to be true
    end
    it "returns an erc list with 1 member" do
      expect(@hypothesis.erc_list.size).to eq 1
    end
    context "and a second contradicting erc" do
      before do
        @erc2 = Erc.new(@constraint_list)
        @erc2.set_l(@constraint_list[0])
        @erc2.set_w(@constraint_list[1])
        @add_erc2_return_value = @hypothesis.add_erc(@erc2)
      end
      it "had add_erc() return false when adding the second erc" do
        expect(@add_erc2_return_value).to be false
      end
      it "is inconsistent" do
        expect(@hypothesis.consistent?).not_to be true
      end
      it "returns an erc list with 2 members" do
        expect(@hypothesis.erc_list.size).to eq 2
      end
    end
    # TODO: spec Hypothesis#dup and Hypothesis#dup_same_lexicon
  end
end # RSpec.describe

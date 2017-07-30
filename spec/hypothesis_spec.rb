# Author: Bruce Tesar

require 'hypothesis'
require 'comparative_tableau'
require 'erc'

RSpec.describe "A hypothesis" do
  before(:each) do
    # TODO: mock the grammar object
    @grammar = SL::Grammar.new
    @hypothesis = Hypothesis.new(@grammar)
  end
  context "with no ercs" do
    it "is consistent" do
      expect(@hypothesis.consistent?).to be true
    end
    it "returns an empty list of ercs" do
      expect(@hypothesis.erc_list.empty?).to be true
    end
  end
  context "with one erc" do
    before do
      @constraint_list = @grammar.system.constraints
      @erc1 = Erc.new(@constraint_list)
      @erc1.set_w(@constraint_list[0])
      @erc1.set_l(@constraint_list[1])
      @hypothesis.add_erc(@erc1)
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
      @hypothesis.add_erc(@erc2)
      end
      it "is inconsistent" do
        expect(@hypothesis.consistent?).not_to be true
      end
      it "returns an erc list with 2 members" do
        expect(@hypothesis.erc_list.size).to eq 2
      end
    end
  end
end

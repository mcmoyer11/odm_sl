# Author: Bruce Tesar

require 'hypothesis'
require 'erc'

RSpec.describe "A hypothesis" do
  before(:each) do
    @grammar = double('grammar')
    @system = instance_double(SL::System)
    @constraint_list = ["C1","C2"]
    allow(@system).to receive(:constraints).and_return(@constraint_list)
    allow(@grammar).to receive(:system).and_return(@system)
  end
  context "with no ercs" do
    before(:each) do
      @hypothesis = Hypothesis.new(@grammar)
    end
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
  context "with one erc added" do
    before do
      @erc1 = Erc.new(@constraint_list)
      @erc1.set_w(@constraint_list[0])
      @erc1.set_l(@constraint_list[1])
      @hypothesis = Hypothesis.new(@grammar)
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
    context "and a second contradicting erc added" do
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
    context "and a second consistent erc added" do
      before do
        @erc2 = Erc.new(@constraint_list)
        @erc2.set_w(@constraint_list[1])
        @add_erc2_return_value = @hypothesis.add_erc(@erc2)
      end
      it "had add_erc() return true when adding the second erc" do
        expect(@add_erc2_return_value).to be true
      end
      it "is consistent" do
        expect(@hypothesis.consistent?).to be true
      end
      it "returns an erc list with 2 members" do
        expect(@hypothesis.erc_list.size).to eq 2
      end
      context "when duplicated with dup" do
        before(:each) do
          @diff_grammar = double('diff_grammar')
          allow(@grammar).to receive(:dup).and_return(@diff_grammar)
          allow(@diff_grammar).to receive(:system).and_return(@system)
          @dup_hyp = @hypothesis.dup
        end
        it "the dup is consistent" do
          expect(@dup_hyp.consistent?).to be true
        end
        it "the dup's erc list is distinct from the original hypothesis erc list" do
          expect(@dup_hyp.erc_list).not_to equal @hypothesis.erc_list
        end
        it "the dup's erc list has 2 members" do
          expect(@dup_hyp.erc_list.size).to eq 2
        end
        it "the dup's erc list that includes erc1" do
          expect(@dup_hyp.erc_list).to include(@erc1)
        end
        it "the dup's erc list that includes erc2" do
          expect(@dup_hyp.erc_list).to include(@erc2)
        end
      end
      context "when duplicated with dup_same_lexicon" do
        before(:each) do
          @diff_grammar = double('diff_grammar')
          allow(@grammar).to receive(:dup_shallow).and_return(@diff_grammar)
          allow(@diff_grammar).to receive(:system).and_return(@system)
          @dup_hyp = @hypothesis.dup_same_lexicon
        end
        it "the dup is consistent" do
          expect(@dup_hyp.consistent?).to be true
        end
        it "the dup's erc list is distinct from the original hypothesis erc list" do
          expect(@dup_hyp.erc_list).not_to equal @hypothesis.erc_list
        end
        it "the dup's erc list has 2 members" do
          expect(@dup_hyp.erc_list.size).to eq 2
        end
        it "the dup's erc list that includes erc1" do
          expect(@dup_hyp.erc_list).to include(@erc1)
        end
        it "the dup's erc list that includes erc2" do
          expect(@dup_hyp.erc_list).to include(@erc2)
        end
      end
    end
  end
  
  context "initialized with one erc" do
    before do
      @erc1 = Erc.new(@constraint_list)
      @erc1.set_w(@constraint_list[0])
      @erc1.set_l(@constraint_list[1])
      @erc_list = double("erc list")
      allow(@erc_list).to receive(:each).and_yield(@erc1)
      allow(@erc_list).to receive(:label).and_return("erc_list_label")
      @hypothesis = Hypothesis.new(@grammar, @erc_list)
    end
    it "is consistent" do
      expect(@hypothesis.consistent?).to be true
    end
    it "returns an erc list with 1 member" do
      expect(@hypothesis.erc_list.size).to eq 1
    end
    it "returns an erc list that includes erc1" do
      expect(@hypothesis.erc_list).to include(@erc1)
    end
    it "contains an erc list distinct from the original" do
      expect(@hypothesis.erc_list).not_to equal @erc_list
    end
    context "and a second contradicting erc added" do
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
      it "returns an erc list that includes erc1" do
        expect(@hypothesis.erc_list).to include(@erc1)
      end
      it "returns an erc list that includes erc2" do
        expect(@hypothesis.erc_list).to include(@erc2)
      end
    end
  end
end # RSpec.describe

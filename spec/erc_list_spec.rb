# Author: Bruce Tesar

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'erc_list'

RSpec.describe Erc_list do
  context "A newly created Erc_list" do
    before(:example) do
      @erc_list = Erc_list.new
    end

    it "is empty" do
      expect(@erc_list.empty?).to be true
    end
    it "has size 0" do
      expect(@erc_list.size).to eq(0)
    end
    it "returns an empty list of constraints" do
      expect(@erc_list.constraint_list).to be_empty
    end
    it "converts to an empty array" do
      expect(@erc_list.to_a).to be_empty
    end    
  end
  
  context "An Erc_list provided with a list of constraints" do
    before(:example) do
      @erc_list = Erc_list.new(constraint_list: ["C1","C2"])
    end
    it "returns a list of the same constraints" do
      expect(@erc_list.constraint_list).to contain_exactly("C1","C2")
    end
    it "raises a RuntimeError when an ERC with different constraints is added" do
      erc_diff = instance_double(Erc, "erc_diff")
      allow(erc_diff).to receive(:constraint_list).and_return(["C3","C4"])
      expect{@erc_list.add(erc_diff)}.to raise_exception(RuntimeError)
    end
  end
  
  context "An Erc_list with one added erc" do
    before(:example) do
      @erc_list = Erc_list.new
      @erc1 = double("erc1")
      allow(@erc1).to receive(:constraint_list).and_return(["C1","C2"])
      allow(@erc1).to receive(:test_cond).and_return(true)
      @erc_list.add(@erc1)
    end
    
    it "is not empty" do
      expect(@erc_list.empty?).not_to be true
    end
    it "has size 1" do
      expect(@erc_list.size).to eq(1)
    end
    it "returns the constraints of the erc" do
      expect(@erc_list.constraint_list).to contain_exactly("C1","C2")
    end
    it "returns true when #any? is satisfied by the erc" do
      expect(@erc_list.any?{|e| e.test_cond}).to be true
    end
    it "returns false when #any? isn't satisfied by the erc" do
      expect(@erc_list.any?{|e| e.nil?}).to be false
    end
    it "returns block-satisfying members for #find_all" do
      found = @erc_list.find_all{|e| e.test_cond} 
      expect(found.to_a).to contain_exactly(@erc1)
    end
    it "returns an Erc_list for #find_all" do
      found = @erc_list.find_all{|e| e.test_cond}
      expect(found).to be_an_instance_of(Erc_list)
    end
    it "returns block-violating members for #reject" do
      found = @erc_list.reject{|e| e.test_cond} 
      expect(found.to_a).to be_empty
    end
    it "returns an Erc_list for #reject" do
      found = @erc_list.reject{|e| e.test_cond}
      expect(found).to be_an_instance_of(Erc_list)
    end
    it "partitions into one satisfying ERC and no other ERCs" do
      true_list, false_list = @erc_list.partition{|e| e.test_cond}
      expect(true_list.to_a).to contain_exactly(@erc1)
      expect(false_list.to_a).to be_empty
    end
    it "partitions into two Erc_list objects" do
      true_list, false_list = @erc_list.partition{|e| e.test_cond}
      expect(true_list).to be_an_instance_of(Erc_list)
      expect(false_list).to be_an_instance_of(Erc_list)
    end
    it "returns a duplicate with a list independent of the original" do
      dup_list = @erc_list.dup
      erc_new = instance_double(Erc, "new erc")
      allow(erc_new).to receive(:constraint_list).and_return(["C1","C2"])
      dup_list.add(erc_new)
      expect(@erc_list.to_a).to contain_exactly(@erc1)
      expect(dup_list.to_a).to contain_exactly(@erc1, erc_new)
    end
    
    context "and a second erc with the same constraints is added" do
      before(:example) do
        @erc2 = double("erc2")
        allow(@erc2).to receive(:constraint_list).and_return(["C2","C1"])
        allow(@erc2).to receive(:test_cond).and_return(false)
        @erc_list.add(@erc2)
      end
      it "has size 2" do
        expect(@erc_list.size).to eq(2)
      end
      it "returns the constraints of the ercs" do
        expect(@erc_list.constraint_list).to contain_exactly("C1","C2")
      end
      it "returns true when #any? is satisfied by one of the ercs" do
        expect(@erc_list.any?{|e| e.test_cond}).to be true
      end
      it "returns false when #any? isn't satisfied by any of the ercs" do
        expect(@erc_list.any?{|e| e.nil?}).to be false
      end
      it "returns an array with block-satisfying members for #find_all" do
        found = @erc_list.find_all{|e| e.test_cond} 
        expect(found.to_a).to contain_exactly(@erc1)
      end
      it "partitions into one satisfying ERC and one other ERC" do
        true_list, false_list = @erc_list.partition{|e| e.test_cond}
        expect(true_list.to_a).to contain_exactly(@erc1)
        expect(false_list.to_a).to contain_exactly(@erc2)
      end
    end
    
    context "and a second erc with different constraints is added" do
      before do
        @erc_diff = instance_double(Erc)
        allow(@erc_diff).to receive(:constraint_list).and_return(["C3","C4"])
      end
      it "raises a RuntimeError" do
        expect{@erc_list.add(@erc_diff)}.to raise_exception(RuntimeError)
      end
    end

    context "and a second erc with a different number of constraints is added" do
      before do
        @erc_diff = instance_double(Erc)
        allow(@erc_diff).to receive(:constraint_list).and_return(["C1","C2","C3"])
      end
      it "raises a RuntimeError" do
        expect{@erc_list.add(@erc_diff)}.to raise_exception(RuntimeError)
      end
    end
  end
  
  context "An empty Erc_list, when ERCS are added from a list" do
    before(:example) do
      @erc_orig = instance_double(Erc)
      @erc_same = instance_double(Erc)
      @erc_diff = instance_double(Erc)
      @erc_again = instance_double(Erc)
      allow(@erc_orig).to receive(:constraint_list).and_return(["C1","C2"])
      allow(@erc_same).to receive(:constraint_list).and_return(["C1","C2"])
      allow(@erc_diff).to receive(:constraint_list).and_return(["C1","C4"])
      allow(@erc_again).to receive(:constraint_list).and_return(["C1","C2"])
      @generic_list = double("generic_list")
    end
    context "of homo-constraint ercs" do
      before(:example) do
        allow(@generic_list).to receive(:each).and_yield(@erc_orig)
                                              .and_yield(@erc_same)
        @new_erc_list = Erc_list.new.add_all(@generic_list)
      end
      it "contains the same number of ercs" do
        expect(@new_erc_list.size).to eq(2)
      end
      it "can be further modified independent of the source list" do
        # This test works because any attempt to add an erc to the source
        # list will fail: test double @generic_list does not accept #add,
        # nor any other method apart from #each.
        @new_erc_list.add(@erc_again)
        expect(@new_erc_list.to_a).to contain_exactly(@erc_again,@erc_orig,@erc_same)
      end
    end
    context "of hetero-constraint ercs" do
      before(:example) do
        allow(@generic_list).to receive(:each).and_yield(@erc_orig)
                                              .and_yield(@erc_diff)
      end
      it "raises a RuntimeError" do
        expect{Erc_list.new.add_all(@generic_list)}.to raise_error(RuntimeError)
      end
    end
  end

  # Testing #consistent?
  
  context "with no ERCs added" do
    before(:example) do
      @erc_list = Erc_list.new
    end
    it "responds that it is consistent" do
      expect(@erc_list.consistent?).to be true
    end
  end
  
  context "with one consistent ERC added" do
    before(:example) do
      @erc_consistent = instance_double(Erc)
      allow(@erc_consistent).to receive(:constraint_list).and_return(["C1","C2"])
      @rcd_class = double("RCD class")
      rcd_result = instance_double(Rcd)
      allow(rcd_result).to receive(:consistent?).and_return(true)
      @erc_list = Erc_list.new(rcd_class: @rcd_class).add(@erc_consistent)
      allow(@rcd_class).to receive(:new).with(@erc_list).and_return(rcd_result)
    end
    it "responds that is is consistent" do
      expect(@erc_list.consistent?).to be true
    end
  end

  context "with one inconsistent ERC added" do
    before(:example) do
      @erc_consistent = instance_double(Erc)
      allow(@erc_consistent).to receive(:constraint_list).and_return(["C1","C2"])
      @rcd_class = double("RCD class")
      rcd_result = instance_double(Rcd)
      allow(rcd_result).to receive(:consistent?).and_return(false)
      @erc_list = Erc_list.new(rcd_class: @rcd_class).add(@erc_consistent)
      allow(@rcd_class).to receive(:new).with(@erc_list).and_return(rcd_result)
    end
    it "responds that it is not consistent" do
      expect(@erc_list.consistent?).to be false
    end
  end
  
end # describe Erc_list

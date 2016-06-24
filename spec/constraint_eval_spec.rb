# Author: Bruce Tesar

require 'constraint_eval'

describe Constraint_eval do
  context "A new Constraint_eval with name Constraint1 set to MARK" do
    before(:each) do
      @constraint_eval = Constraint_eval.new("Constraint1", "Con1", Constraint_eval::MARK, "add_one")
    end

    it "should return its name" do
      expect(@constraint_eval.name).to eq("Constraint1")
    end
    
    it "should be a markedness constraint" do
      expect(@constraint_eval.markedness?).to be true
    end
    
    it "should not be a faithfulness constraint" do
      expect(@constraint_eval.faithfulness?).to be false
    end
  end
  
  context "A new Constraint_eval set to FAITH" do
    before(:each) do
      @constraint_eval = Constraint_eval.new("FCon", "1", Constraint_eval::FAITH, "add_one")
    end

    it "should return its name" do
      expect(@constraint_eval.name).to eq("FCon")
    end
    
    it "should not be a markedness constraint" do
      expect(@constraint_eval.markedness?).to be false
    end
    
    it "should be a faithfulness constraint" do
      expect(@constraint_eval.faithfulness?).to be true
    end
  end

  context "A new constraint_eval set properly to MARK" do
    it "should not raise a RuntimeError" do
      expect {Constraint_eval.new("FCon", "1", Constraint_eval::MARK, "a")}.not_to raise_error
    end
  end
  
  context "A new Constraint_eval with type set to OTHER" do
    it "should raise a RuntimeError" do
      expect {Constraint_eval.new("FCon", "1", "OTHER", "a")}.to raise_error(RuntimeError)
    end
  end

end # describe Constraint_eval

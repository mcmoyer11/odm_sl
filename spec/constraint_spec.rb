# Author: Bruce Tesar

require 'constraint'

describe Constraint do
  context "A new markedness Constraint with name Constraint1 and ID Con1" do
    before(:each) do
      @constraint = Constraint.new("Constraint1", "Con1", Constraint::MARK, 'a')
    end

    it "should return name string Constraint1" do
      expect(@constraint.name).to eq("Constraint1")
    end

    it "should return ID string Con1" do
      expect(@constraint.id).to eq("Con1")
    end
    
    it "should be a markedness constraint" do
      expect(@constraint.markedness?).to be true
    end
    
    it "should not be a faithfulness constraint" do
      expect(@constraint.faithfulness?).to be false
    end

    it "should return a to_s string of Con1:Constraint1" do
      expect(@constraint.to_s).to eq("Con1:Constraint1")
    end
  end

  context "A new faithfulness Constraint with name Cname and ID Cid" do
    before(:each) do
      @constraint = Constraint.new("Cname", "Cid", Constraint::FAITH, 'a')
    end

    it "should return name string Cname" do
      expect(@constraint.name).to eq("Cname")
    end

    it "should return ID string Cid" do
      expect(@constraint.id).to eq("Cid")
    end
    
    it "should not be a markedness constraint" do
      expect(@constraint.markedness?).to be false
    end
    
    it "should be a faithfulness constraint" do
      expect(@constraint.faithfulness?).to be true
    end

    it "should return a to_s string of Cid:Cname" do
      expect(@constraint.to_s).to eq("Cid:Cname")
    end
  end
  
  context "A constraint" do
    before(:each) do
      @buddy1 = Constraint.new("buddy", "b", Constraint::MARK, 'a')
      @buddy2 = Constraint.new("buddy", "b", Constraint::MARK, 'a')
      @notbuddy = Constraint.new("notbuddy", "n", Constraint::MARK, 'a')
    end
    
    it "should be == to another constraint with the same name" do
      expect(@buddy1==@buddy2).to be true
    end
    
    it "should be eql? to another constraint with the same name" do
      expect(@buddy1.eql?(@buddy2)).to be true
    end
    
    it "should have the same hash value as another constraint with the same name" do
      expect(@buddy1.hash).to eq(@buddy2.hash)
    end
    
    it "should not be == equal to a constraint with a different name" do
      expect(@buddy1==@notbuddy).to be false
    end
    
    it "should not be eql? to a constraint with a different name" do
      expect(@buddy1.eql?(@notbuddy)).to be false
    end
    
    it "should not have the same hash value as a constraint with a different name" do
      expect(@buddy1.hash).not_to eq(@notbuddy.hash)
    end
  end

  context "A new constraint set properly to MARK" do
    it "should not raise a RuntimeError" do
      expect {Constraint.new("FCon", "1", Constraint::MARK, 'a')}.not_to raise_error
    end
  end
  
  context "A new Constraint with type set to OTHER" do
    it "should raise a RuntimeError" do
      expect {Constraint.new("FCon", "1", "OTHER", 'a')}.to raise_error(RuntimeError)
    end
  end

end # describe Constraint

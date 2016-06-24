# Author: Bruce Tesar

require 'constraint'

describe Constraint do
  context "A new Constraint with name Constraint1 and ID Con1" do
    before(:each) do
      @constraint = Constraint.new("Constraint1", "Con1")
    end

    it "should return name string Constraint1" do
      expect(@constraint.name).to eq("Constraint1")
    end

    it "should return ID string Con1" do
      expect(@constraint.id).to eq("Con1")
    end
    
    it "should return a to_s string of Con1:Constraint1" do
      expect(@constraint.to_s).to eq("Con1:Constraint1")
    end
  end
  
  context "A constraint" do
    before(:each) do
      @buddy1 = Constraint.new("buddy", "b")
      @buddy2 = Constraint.new("buddy", "b")
      @notbuddy = Constraint.new("notbuddy", "n")
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

end # describe Constraint

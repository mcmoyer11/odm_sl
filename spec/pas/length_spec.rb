# Author: Bruce Tesar

require 'pas/length_feat'

RSpec.describe PAS::Length_feat do
  context "A new Length" do
    before(:each) do
      @length = PAS::Length_feat.new
    end
    it "should be unset" do
      expect(@length.unset?).to be true
    end
    it "should not be short" do
      expect(@length.short?).to be false
    end
    it "should not be long" do
      expect(@length.long?).to be false
    end
    it "should return a string value of length=unset" do
      expect(@length.to_s).to eq("length=unset")
    end
    it "should accept SHORT as a valid value" do
      expect(@length.valid_value?(PAS::Length_feat::SHORT)).to be true
    end
    it "should accept LONG as a valid value" do
      expect(@length.valid_value?(PAS::Length_feat::LONG)).to be true
    end
    it "should not accept INVALID as a valid value" do
      expect(@length.valid_value?("INVALID")).to be false
    end
    
    context "set to short" do
      before(:each) do
        @length.set_short
      end
      it "should be set" do
        expect(@length.unset?).to be false
      end
      it "should be short" do
        expect(@length.short?).to be true
      end
      it "should not be long" do
        expect(@length.long?).to be false
      end
      it "should return a string value of length=short" do
        expect(@length.to_s).to eq("length=short")
      end
    end
    
    context "set to long" do
      before(:each) do
        @length.set_long
      end
      it "should be set" do
        expect(@length.unset?).to be false
      end
      it "should not be short" do
        expect(@length.short?).to be false
      end
      it "should be long" do
        expect(@length.long?).to be true
      end
      it "should return a string value of length=long" do
        expect(@length.to_s).to eq("length=long")
      end
    end
  end
end # describe Length

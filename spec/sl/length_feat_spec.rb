# Author: Bruce Tesar

require_relative '../../lib/sl/length_feat'

RSpec.describe SL::Length_feat do
  context "A new Length_feat" do
    before(:each) do
      @length_feat = SL::Length_feat.new
    end
    it "should be unset" do
      expect(@length_feat.unset?).to be true
    end
    it "should not be short" do
      expect(@length_feat.short?).to be false
    end
    it "should not be long" do
      expect(@length_feat.long?).to be false
    end
    it "should return a string value of length=unset" do
      expect(@length_feat.to_s).to eq("length=unset")
    end
    it "should accept SHORT as a valid value" do
      expect(@length_feat.valid_value?(SL::Length_feat::SHORT)).to be true
    end
    it "should accept LONG as a valid value" do
      expect(@length_feat.valid_value?(SL::Length_feat::LONG)).to be true
    end
    it "should not accept INVALID as a valid value" do
      expect(@length_feat.valid_value?("INVALID")).to be false
    end
    
    context "set to short" do
      before(:each) do
        @length_feat.set_short
      end
      it "should be set" do
        expect(@length_feat.unset?).to be false
      end
      it "should be short" do
        expect(@length_feat.short?).to be true
      end
      it "should not be long" do
        expect(@length_feat.long?).to be false
      end
      it "should return a string value of length=short" do
        expect(@length_feat.to_s).to eq("length=short")
      end
    end
    
    context "set to long" do
      before(:each) do
        @length_feat.set_long
      end
      it "should be set" do
        expect(@length_feat.unset?).to be false
      end
      it "should not be short" do
        expect(@length_feat.short?).to be false
      end
      it "should be long" do
        expect(@length_feat.long?).to be true
      end
      it "should return a string value of length=long" do
        expect(@length_feat.to_s).to eq("length=long")
      end
    end
  end
end # describe Length_feat

# Author: Bruce Tesar

require 'pas/stress_feat'

RSpec.describe PAS::Stress_feat do
  context "A new Stress_feat" do
    before(:each) do
      @stress_feat = PAS::Stress_feat.new
    end

    it "should be unset" do
      expect(@stress_feat.unset?).to be true
    end
    it "should not be unstressed" do
      expect(@stress_feat.unstressed?).to be false
    end
    it "should not be stressed" do
      expect(@stress_feat.main_stress?).to be false
    end
    it "should return a string value of stress=unset" do
      expect(@stress_feat.to_s).to eq("stress=unset")
    end
    it "should accept UNSTRESSED as a valid value" do
      expect(@stress_feat.valid_value?(PAS::Stress_feat::UNSTRESSED)).to be true
    end
    it "should accept MAIN_STRESS as a valid value" do
      expect(@stress_feat.valid_value?(PAS::Stress_feat::MAIN_STRESS)).to be true
    end
    it "should not accept INVALID as a valid value" do
      expect(@stress_feat.valid_value?("INVALID")).to be false
    end
    
    context "set to unstressed" do
      before(:each) do
        @stress_feat.set_unstressed
      end
      it "should be set" do
        expect(@stress_feat.unset?).to be false
      end
      it "should be unstressed" do
        expect(@stress_feat.unstressed?).to be true
      end
      it "should not be stressed" do
        expect(@stress_feat.main_stress?).to be false
      end
      it "should return a string value of stress=unstressed" do
        expect(@stress_feat.to_s).to eq("stress=unstressed")
      end
    end
    
    context "set to main_stress" do
      before(:each) do
        @stress_feat.set_main_stress
      end
      it "should be set" do
        expect(@stress_feat.unset?).to be false
      end
      it "should not be unstressed" do
        expect(@stress_feat.unstressed?).to be false
      end
      it "should be stressed" do
        expect(@stress_feat.main_stress?).to be true
      end
      it "should return a string value of stress=main_stress" do
        expect(@stress_feat.to_s).to eq("stress=main_stress")
      end
    end
  end
end # describe PAS::Stress_feat

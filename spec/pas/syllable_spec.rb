# Author: Bruce Tesar

require 'pas/syllable'
require 'feature'

RSpec.describe PAS::Syllable do
  context "A new Syllable" do
    before(:each) do
      @syllable = PAS::Syllable.new
    end
    it "should have an unset stress feature" do
      expect(@syllable.stress_unset?).to be true
    end
    it "should have an unset length feature" do
      expect(@syllable.length_unset?).to be true
    end
    it 'should have morpheme ""' do
      expect(@syllable.morpheme).to eq("")
    end
    it "should not have main stress" do
      expect(@syllable.main_stress?).to be false
    end
    it "should not be unstressed" do
      expect(@syllable.unstressed?).to be false
    end
    it "should not be long" do
      expect(@syllable.long?).to be false
    end
    it "should not be short" do
      expect(@syllable.short?).to be false
    end
    it "should have string representation ??" do
      expect(@syllable.to_s).to eq("??")
    end
    context "when #each_feature is called" do
      before(:each) do
        @features = []
        @syllable.each_feature{|f| @features << f}
      end
      it "should yield two features" do
        expect(@features.size).to eq(2)
      end
      it "should yield a length feature" do
        expect(@features[0].type).to eq(PAS::Length::LENGTH)
      end
      it "should yield a stress feature" do
        expect(@features[1].type).to eq(PAS::Stress_feat::STRESS)
      end
    end
    context "when set to unstressed and short" do
      before(:each) do
        @syllable.set_unstressed.set_short
      end
      context "#get_feature returns a stress feature" do
        before(:each) do
          @s_feat = @syllable.get_feature(PAS::Stress_feat::STRESS)
        end
        it "returns a stress feature that is of type STRESS" do
          expect(@s_feat.type).to eq(PAS::Stress_feat::STRESS)
        end
        it "returns a stress feature that is unstressed" do
          expect(@s_feat.unstressed?).to be true
        end
      end
      context "#get_feature returns a length feature" do
        before(:each) do
          @s_feat = @syllable.get_feature(PAS::Length::LENGTH)
        end
        it "returns a length feature that is of type LENGTH" do
          expect(@s_feat.type).to eq(PAS::Length::LENGTH)
        end
        it "returns a length feature that is short" do
          expect(@s_feat.short?).to be true
        end
      end
      it "get_feature raises an exception when given an invalid type" do
        expect{@syllable.get_feature("not_a_type")}.to raise_exception(RuntimeError)
      end
    end
    context "when #set_feature sets stress with value main stress" do
      before(:each) do
        s_feat = PAS::Stress_feat.new
        s_feat.set_main_stress
        @syllable.set_feature(s_feat.type, s_feat.value)
      end
      it "has a set stress feature" do
        expect(@syllable.stress_unset?).to be false
      end
      it "has main stress" do
        expect(@syllable.main_stress?).to be true
      end
    end
    it "#set_feature raises an exception when given an invalid feature type" do
      expect{@syllable.set_feature("invalid", "value")}.to raise_exception(RuntimeError)
    end
    it "#set_feature does not raise an invalid feature exception when given an unset feature value" do
      expect{@syllable.set_feature(PAS::Length::LENGTH, Feature::UNSET)}.not_to raise_exception
    end
    
    context "when set to main stress" do
      before(:each) do
        @syllable.set_main_stress
      end
      it "should not have an unset stress feature" do
        expect(@syllable.stress_unset?).to be false
      end
      it "should have an unset length feature" do
        expect(@syllable.length_unset?).to be true
      end
      it "should have main stress" do
        expect(@syllable.main_stress?).to be true
      end
      it "should not be unstressed" do
        expect(@syllable.unstressed?).to be false
      end
    end
    context "when set to long" do
      before(:each) do
        @syllable.set_long
      end
      it "should have an unset stress feature" do
        expect(@syllable.stress_unset?).to be true
      end
      it "should not have an unset length feature" do
        expect(@syllable.length_unset?).to be false
      end
      it "should be long" do
        expect(@syllable.long?).to be true
      end
      it "should not be short" do
        expect(@syllable.short?).to be false
      end
    end
  end
  
  context "s1 stressed and short, s2 stressed and long" do
    before(:each) do
      @s1 = PAS::Syllable.new
      @s1.set_main_stress; @s1.set_short
      @s2 = PAS::Syllable.new
      @s2.set_main_stress; @s2.set_long
    end
    it "should not be ==" do
      expect(@s1==@s2).to be false
    end
    it "should not be eql?" do
      expect(@s1.eql?(@s2)).to be false
    end
    context "a dup of s1" do
      before(:each) do
        @dups1 = @s1.dup
      end
      it "should be == s1" do
        expect(@dups1==@s1).to be true
      end
      it "should be eql? to s1" do
        expect(@dups1.eql?(@s1)).to be true
      end
      it "should not be #equal? to s1" do
        expect(@dups1.equal?(@s1)).to be false
      end
    end
  end
  context "s1 stressed and short, s2 stressed and short" do
    before(:each) do
      @s1 = PAS::Syllable.new
      @s1.set_main_stress; @s1.set_short
      @s2 = PAS::Syllable.new
      @s2.set_main_stress; @s2.set_short
    end
    it "should be ==" do
      expect(@s1==@s2).to be true
    end
    it "should be eql?" do
      expect(@s1.eql?(@s2)).to be true
    end
  end
  
end # describe PAS::Syllable

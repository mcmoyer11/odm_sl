# Author: Bruce Tesar

require 'sl/syllable'

describe SL::Syllable do
  context "A new Syllable with no constructor parameters" do
    before(:each) do
      @syllable = SL::Syllable.new
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
      @s1 = SL::Syllable.new
      @s1.set_main_stress; @s1.set_short
      @s2 = SL::Syllable.new
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
      @s1 = SL::Syllable.new
      @s1.set_main_stress; @s1.set_short
      @s2 = SL::Syllable.new
      @s2.set_main_stress; @s2.set_short
    end
    it "should be ==" do
      expect(@s1==@s2).to be true
    end
    it "should be eql?" do
      expect(@s1.eql?(@s2)).to be true
    end
  end
  
  #TODO: specs for the generic interface: #each_feature, #get_feature
end # describe SL::Syllable

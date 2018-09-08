#Author: Morgan Moyer
#

require_relative '../lib/output'

RSpec.describe Output do
  before(:each) do
    @output = Output.new
  end
  context "with one stressed syllable" do
    before(:each) do
      @syl = double("Syllable1")
      allow(@syl).to receive(:unstressed?).and_return(false)
      allow(@syl).to receive(:main_stress?).and_return(true)
      allow(@syl).to receive(:stress_unset?).and_return(false)
      @output << @syl
    end
    it "should have a main stress" do
      expect(@output.main_stress?).to be true
    end
  end
  context "with one unstressed syllable" do
    before(:each) do
      @syl = double("Syllable1")
      allow(@syl).to receive(:unstressed?).and_return(true)
      allow(@syl).to receive(:main_stress?).and_return(false)
      allow(@syl).to receive(:stress_unset?).and_return(false)
      @output << @syl
    end
    it "should not have a main stress" do
      expect(@output.main_stress?).to be false
    end
  end
  context "with one stress and one unstressed syllable" do
    before(:each) do
      @syl1 = double("Syllable1")
      allow(@syl1).to receive(:unstressed?).and_return(true)
      allow(@syl1).to receive(:main_stress?).and_return(false)
      allow(@syl1).to receive(:stress_unset?).and_return(false)
      @output << @syl1
      @syl2 = double("Syllable1")
      allow(@syl2).to receive(:unstressed?).and_return(false)
      allow(@syl2).to receive(:main_stress?).and_return(true)
      allow(@syl2).to receive(:stress_unset?).and_return(false)
      @output << @syl2      
    end
    it "should have a main stress" do
      expect(@output.main_stress?).to be true
    end
  end
end


# Author: Bruce Tesar

require_relative '../lib/ui_correspondence'

RSpec.describe UICorrespondence do
  let(:uf1){double('uf1')}
  let(:in1){double('in1')}
  let(:uf2){double('uf2')}
  let(:in2){double('in2')}
  context "that is empty" do
    before(:example) do
      @ui_corr = UICorrespondence.new
    end
    it "states that uf1 does not have an input correspondent" do
      expect(@ui_corr.in_corr?(uf1)).to be false
    end
    it "states that uf2 does not have an input correspondent" do
      expect(@ui_corr.in_corr?(uf2)).to be false
    end
    it "states that in1 does not have a uf correspondent" do
      expect(@ui_corr.under_corr?(in1)).to be false
    end
    it "states that in2 does not have a uf correspondent" do
      expect(@ui_corr.under_corr?(in2)).to be false
    end
  end
  
  context "given a UI pair" do
    before(:example) do
      @ui_corr = UICorrespondence.new
      @return_value = @ui_corr.add_corr(uf1, in1)
    end
    it "gives the input correspondent for uf1" do
      expect(@ui_corr.in_corr(uf1)).to eq in1
    end
    it "states that uf1 has an input correspondent" do
      expect(@ui_corr.in_corr?(uf1)).to be true
    end
    it "states that uf2 does not have an input correspondent" do
      expect(@ui_corr.in_corr?(uf2)).to be false
    end
    it "gives the uf correspondent for in1" do
      expect(@ui_corr.under_corr(in1)).to eq uf1
    end
    it "states that in1 has a uf correspondent" do
      expect(@ui_corr.under_corr?(in1)).to be true
    end
    it "states that in2 does not have a uf correspondent" do
      expect(@ui_corr.under_corr?(in2)).to be false
    end
    it "returns a reference to itself" do
      expect(@return_value).to equal @ui_corr
    end
    it "gives nil for the uf correspondent of in1" do
      expect(@ui_corr.in_corr(in1)).to be_nil
    end
    it "gives nil for the input correspondent of uf1" do
      expect(@ui_corr.under_corr(uf1)).to be_nil
    end
  end
  
  context "given two UI pairs" do
    before(:example) do
      @uf_corr = UICorrespondence.new
      @return_value = @uf_corr.add_corr(uf1, in1).add_corr(uf2, in2)
    end
    it "gives the output correspondent for uf1" do
      expect(@uf_corr.in_corr(uf1)).to eq in1
    end
    it "states that uf1 has an output correspondent" do
      expect(@uf_corr.in_corr?(uf1)).to be true
    end
    it "gives the output correspondent for uf2" do
      expect(@uf_corr.in_corr(uf2)).to eq in2
    end
    it "states that uf2 has an output correspondent" do
      expect(@uf_corr.in_corr?(uf2)).to be true
    end
    it "gives the input correspondent for in1" do
      expect(@uf_corr.under_corr(in1)).to eq uf1
    end
    it "states that in1 has an input correspondent" do
      expect(@uf_corr.under_corr?(in1)).to be true
    end
    it "gives the input correspondent for in2" do
      expect(@uf_corr.under_corr(in2)).to eq uf2
    end
    it "states that in2 has an input correspondent" do
      expect(@uf_corr.under_corr?(in2)).to be true
    end
  end
end # RSpec.describe UICorrespondence

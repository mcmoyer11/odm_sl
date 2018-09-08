# Author: Bruce Tesar

require_relative '../lib/io_correspondence'

RSpec.describe IOCorrespondence do
    let(:in1){double('in1')}
    let(:out1){double('out1')}
    let(:in2){double('in2')}
    let(:out2){double('out2')}
  context "that is empty" do
    before(:example) do
      @io_corr = IOCorrespondence.new
    end
    it "states that in1 does not have an output correspondent" do
      expect(@io_corr.out_corr?(in1)).to be false
    end
    it "states that in2 does not have an output correspondent" do
      expect(@io_corr.out_corr?(in2)).to be false
    end
    it "states that out1 does not have an input correspondent" do
      expect(@io_corr.in_corr?(out1)).to be false
    end
    it "states that out2 does not have an input correspondent" do
      expect(@io_corr.in_corr?(out2)).to be false
    end
  end
  
  context "given an IO pair" do
    before(:example) do
      @io_corr = IOCorrespondence.new
      @return_value = @io_corr.add_corr(in1, out1)
    end
    it "gives the output correspondent for in1" do
      expect(@io_corr.out_corr(in1)).to eq out1
    end
    it "states that in1 has an output correspondent" do
      expect(@io_corr.out_corr?(in1)).to be true
    end
    it "states that in2 does not have an output correspondent" do
      expect(@io_corr.out_corr?(in2)).to be false
    end
    it "gives the input correspondent for out1" do
      expect(@io_corr.in_corr(out1)).to eq in1
    end
    it "states that out1 has an input correspondent" do
      expect(@io_corr.in_corr?(out1)).to be true
    end
    it "states that out2 does not have an input correspondent" do
      expect(@io_corr.in_corr?(out2)).to be false
    end
    it "returns a reference to itself" do
      expect(@return_value).to equal @io_corr
    end
    it "gives nil for the output correspondent of out1" do
      expect(@io_corr.out_corr(out1)).to be_nil
    end
    it "gives nil for the input correspondent of in1" do
      expect(@io_corr.in_corr(in1)).to be_nil
    end
  end
  
  context "given two IO pairs" do
    before(:example) do
      @io_corr = IOCorrespondence.new
      @return_value = @io_corr.add_corr(in1, out1).add_corr(in2, out2)
    end
    it "gives the output correspondent for in1" do
      expect(@io_corr.out_corr(in1)).to eq out1
    end
    it "states that in1 has an output correspondent" do
      expect(@io_corr.out_corr?(in1)).to be true
    end
    it "gives the output correspondent for in2" do
      expect(@io_corr.out_corr(in2)).to eq out2
    end
    it "states that in2 has an output correspondent" do
      expect(@io_corr.out_corr?(in2)).to be true
    end
    it "gives the input correspondent for out1" do
      expect(@io_corr.in_corr(out1)).to eq in1
    end
    it "states that out1 has an input correspondent" do
      expect(@io_corr.in_corr?(out1)).to be true
    end
    it "gives the input correspondent for out2" do
      expect(@io_corr.in_corr(out2)).to eq in2
    end
    it "states that out2 has an input correspondent" do
      expect(@io_corr.in_corr?(out2)).to be true
    end
  end
end # RSpec.describe IOCorrespondence

# Author: Bruce Tesar

require_relative '../lib/input'

RSpec.describe Input do
  let(:morphword){double('morphword')}
  let(:morphword_dup){double('morphword_dup')}
  let(:ui_corr){double('ui_corr')}
  let(:feature_instance_class){double('feature_instance_class')}
  before(:example) do
    allow(morphword).to receive(:dup).and_return(morphword_dup)
  end
  context "with one element" do
    let(:element1){double('element1')}
    before(:example) do
      @input = Input.new(morphword: morphword, ui_corr: ui_corr)
      @input << element1
    end
    it "has size 1" do
      expect(@input.size).to eq 1
    end
    it "returns the element" do
      expect(@input[0]).to eq element1
    end
    it "returns the morphword" do
      expect(@input.morphword).to eq morphword
    end
    it "has the UI correspondence" do
      expect(@input.ui_corr).to eq ui_corr
    end
    
    context "and a second element" do
      let(:element2){double('element2')}
      before(:example) do
        @input << element2
      end
      it "has size 2" do
        expect(@input.size).to eq 2
      end
      it "has element1 first" do
        expect(@input[0]).to eq element1
      end
      it "has element2 second" do
        expect(@input[1]).to eq element2
      end
    end
  end
  
  context "two inputs" do
    let(:element_1_1){double('element_1_1')}
    let(:element_1_2){double('element_1_2')}
    let(:element_2_1){double('element_2_1')}
    let(:element_2_2){double('element_2_2')}
    context "each with two equivalent elements" do
      before(:example) do
        allow(element_1_1).to receive(:==).with(element_2_1).and_return(true)
        allow(element_1_2).to receive(:==).with(element_2_2).and_return(true)
        @input1 = Input.new(morphword: morphword, ui_corr: ui_corr)
        @input1 << element_1_1 << element_1_2
        @input2 = Input.new(morphword: morphword, ui_corr: ui_corr)
        @input2 << element_2_1 << element_2_2
      end
      # Regression spec making sure that methods taking blocks, like
      # #each_index, are properly delegated to the internal element list.
      it "yields 2 indices" do
        expect{|probe| @input1.each_index(&probe)}.to yield_control.exactly(2).times
      end
      it "are ==" do
        expect(@input1==@input2).to be true
      end
      it "are eql" do
        expect(@input1.eql?(@input2)).to be true
      end
      it "have equivalent first elements" do
        expect(@input1[0]==@input2[0]).to be true
      end
      it "each have size 2" do
        expect(@input1.size).to eq 2
        expect(@input2.size).to eq 2
      end
    end
    context "each with a distinct element" do
      before(:example) do
        allow(element_1_1).to receive(:==).and_return(false)
        allow(element_1_1).to receive(:==).with(element_2_1).and_return(true)
        allow(element_1_2).to receive(:==).and_return(false)
        @input1 = Input.new(morphword: morphword, ui_corr: ui_corr)
        @input1 << element_1_1 << element_1_2
        @input2 = Input.new(morphword: morphword, ui_corr: ui_corr)
        @input2 << element_2_1 << element_2_2
      end
      it "have size 2" do
        expect(@input1.size).to eq 2
      end
      it "have equivalent first elements" do
        expect(@input1[0]==@input2[0]).to be true
      end
      it "have non-equivalent second elements" do
        expect(@input1[1]==@input2[1]).to be false
      end
      it "yields 2 indices" do
        expect{|probe| @input1.each_index(&probe)}.to yield_control.exactly(2).times
      end
      it "are not ==" do
        expect(@input1==@input2).to be false
      end
      it "are not eql" do
        expect(@input1.eql?(@input2)).to be false
      end
    end
    context "with the first having more elements than the second" do
      before(:example) do
        allow(element_1_1).to receive(:==).with(element_2_1).and_return(true)
        @input1 = Input.new(morphword: morphword, ui_corr: ui_corr)
        @input1 << element_1_1 << element_1_2
        @input2 = Input.new(morphword: morphword, ui_corr: ui_corr)
        @input2 << element_2_1
      end
      it "are not ==" do
        expect(@input1==@input2).to be false
      end
      it "are not eql" do
        expect(@input1.eql?(@input2)).to be false
      end
    end
  end
  
  context "and a dup" do
    let(:element_1_1){double('element_1_1')}
    let(:element_1_2){double('element_1_2')}
    let(:element_dup_1){double('element_dup_1')}
    let(:element_dup_2){double('element_dup_2')}
    let(:uf1){double('uf1')}
    let(:uf2){double('uf2')}
    before(:example) do
      allow(element_1_1).to receive(:dup).and_return(element_dup_1)
      allow(element_1_2).to receive(:dup).and_return(element_dup_2)
      allow(element_1_1).to receive(:==).and_return(false)
      allow(element_1_1).to receive(:==).with(element_dup_1).and_return(true)
      allow(element_1_2).to receive(:==).and_return(false)
      allow(element_1_2).to receive(:==).with(element_dup_2).and_return(true)
      allow(ui_corr).to receive(:under_corr).with(element_1_1).and_return(uf1)
      allow(ui_corr).to receive(:under_corr).with(element_1_2).and_return(uf2)
      @input = Input.new(morphword: morphword, ui_corr: ui_corr)
      @input << element_1_1 << element_1_2
      @input_dup = @input.dup
    end
    it "have the same number of elements" do
      expect(@input.size).to eq @input_dup.size
    end
    it "have equivalent elements" do
      expect(@input==@input_dup).to be true
    end
    it "do not have identical elements" do
      expect(@input[0].equal?(@input_dup[0])).to be false
      expect(@input[1].equal?(@input_dup[1])).to be false
    end
    it "the dup's first underlying element is the same" do
      expect(@input_dup.ui_corr.under_corr(@input_dup[0])).to equal uf1
    end
    it "the dup's second underlying element is the same" do
      expect(@input_dup.ui_corr.under_corr(@input_dup[1])).to equal uf2
    end
    it "the dup has a dup of the morphword" do
      expect(@input_dup.morphword).to eq morphword_dup
    end
  end
  
  context "with two segments each with two features" do
    let(:seg1){double('seg1')}
    let(:seg2){double('seg2')}
    let(:feat_1_1){double('feat_1_1')}
    let(:feat_1_2){double('feat_1_2')}
    let(:feat_2_1){double('feat_2_1')}
    let(:feat_2_2){double('feat_2_2')}
    let(:finst_1_1){double('finst_1_1')}
    let(:finst_1_2){double('finst_1_2')}
    let(:finst_2_1){double('finst_2_1')}
    let(:finst_2_2){double('finst_2_2')}
    before(:example) do
      allow(seg1).to receive(:each_feature).and_yield(feat_1_1).and_yield(feat_1_2)
      allow(seg2).to receive(:each_feature).and_yield(feat_2_1).and_yield(feat_2_2)
      allow(feature_instance_class).to receive(:new).with(seg1,feat_1_1).and_return(finst_1_1)
      allow(feature_instance_class).to receive(:new).with(seg1,feat_1_2).and_return(finst_1_2)
      allow(feature_instance_class).to receive(:new).with(seg2,feat_2_1).and_return(finst_2_1)
      allow(feature_instance_class).to receive(:new).with(seg2,feat_2_2).and_return(finst_2_2)
      @input = Input.new(morphword: morphword, ui_corr: ui_corr,
        feature_instance_class: feature_instance_class)
      @input << seg1 << seg2
    end
    it "yields four feature instances in succession" do
      expect{|probe| @input.each_feature(&probe)}.to yield_successive_args(finst_1_1, finst_1_2, finst_2_1, finst_2_2)
    end
    
  end
end # RSpec.describe Input

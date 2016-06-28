# Author: Bruce Tesar

require 'feature'

describe Feature do
  context "A new Feature of type GROG" do
    before(:each) do
      @feature = Feature.new("GROG")
    end

    it "is unset" do
      expect(@feature.unset?).to be true
    end
    it "has type GROG" do
      expect(@feature.type).to eq("GROG")
    end
    it "has value Feature::UNSET" do
      expect(@feature.value).to eq(Feature::UNSET)
    end
    
    context "set to value KILB" do
      before(:each) do
        @feature.value = "KILB"
      end
      it "is not unset" do
        expect(@feature.unset?).to be false
      end
      it "has value KILB" do
        expect(@feature.value).to eq("KILB")
      end
      context "with another feature with type GROG and value KILB" do
        before(:each) do
          @feat2 = Feature.new("GROG")
          @feat2.value = "KILB"          
        end
        it "the features are ==" do
          expect(@feature==@feat2).to be true
        end
        it "the features are eql?" do
          expect(@feature.eql?(@feat2)).to be true
        end
      end
      context "with another feature with value BORK" do
        before(:each) do
          @feat2 = Feature.new("GROG")
          @feat2.value = "BORK"          
        end
        it "the features are not ==" do
          expect(@feature==@feat2).to be false
        end
        it "the features are not eql?" do
          expect(@feature.eql?(@feat2)).to be false
        end
      end
      context "with another feature with type OOPH" do
        before(:each) do
          @feat2 = Feature.new("OOPH")
          @feat2.value = "KILB"          
        end
        it "the features are not ==" do
          expect(@feature==@feat2).to be false
        end
        it "the features are not eql?" do
          expect(@feature.eql?(@feat2)).to be false
        end
      end
    end
  end
end # describe Feature

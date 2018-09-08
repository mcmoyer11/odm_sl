# Author: Bruce Tesar

require_relative '../lib/constraint_preference_image'

RSpec.describe ConstraintPreferenceImage do
  context "with 2 constraints" do
    let(:con1){double('con1')}
    let(:con2){double('con2')}
    before(:each) do
      allow(con1).to receive(:to_s).and_return('con1')
      allow(con2).to receive(:to_s).and_return('con2')      
    end
    context "and 2 ercs" do
      let(:erc1){double('erc1')}
      let(:erc2){double('erc2')}
      before(:each) do
        allow(erc1).to receive(:l?).with(con1).and_return(false)
        allow(erc1).to receive(:w?).with(con1).and_return(true)
        allow(erc1).to receive(:l?).with(con2).and_return(true)
        allow(erc1).to receive(:w?).with(con2).and_return(false)
        allow(erc2).to receive(:l?).with(con1).and_return(false)
        allow(erc2).to receive(:w?).with(con1).and_return(false)
        allow(erc2).to receive(:l?).with(con2).and_return(false)
        allow(erc2).to receive(:w?).with(con2).and_return(true)
        @cp_image = ConstraintPreferenceImage.new([erc1,erc2], [con1,con2])
      end
      it "gives a sheet with 3 rows" do
        expect(@cp_image.row_count).to eq 3
      end
      it "gives a sheet with 2 columns" do
        expect(@cp_image.col_count).to eq 2
      end
      it "has col 1 heading 'con1'" do
        expect(@cp_image[1,1]).to eq 'con1'
      end
      it "has col 2 heading 'con2'" do
        expect(@cp_image[1,2]).to eq 'con2'
      end
      it "has erc1 con1 preference W" do
        expect(@cp_image[2,1]).to eq 'W'
      end
      it "has erc1 con2 preference L" do
        expect(@cp_image[2,2]).to eq 'L'      
      end
      it "has erc2 con1 preference e" do
        expect(@cp_image[3,1]).to eq nil
      end
      it "has erc2 con2 preference W" do
        expect(@cp_image[3,2]).to eq 'W'      
      end
    end
    
    context "and no ercs" do
      before(:each) do
        @cp_image = ConstraintPreferenceImage.new([], [con1,con2])
      end
      it "gives a sheet with 1 row" do
        expect(@cp_image.row_count).to eq 1
      end
      it "gives a sheet with 2 columns" do
        expect(@cp_image.col_count).to eq 2
      end
      it "has col 1 heading 'con1'" do
        expect(@cp_image[1,1]).to eq 'con1'
      end
      it "has col 2 heading 'con2'" do
        expect(@cp_image[1,2]).to eq 'con2'
      end
    end
  end
  
  context "with no constraints and no ercs" do
    before(:each) do
      @cp_image = ConstraintPreferenceImage.new([], [])      
    end
    it "gives a sheet with 1 row" do
      expect(@cp_image.row_count).to eq 1
    end
    it "gives a sheet with 1 column" do
      expect(@cp_image.col_count).to eq 1
    end
    it "has a single cell containing nil" do
      expect(@cp_image[1,1]).to eq nil
    end
  end
end # RSpec.describe ConstraintPreferenceImage

# Author: Bruce Tesar

require_relative '../lib/comparative_tableau_image'
require_relative '../lib/sheet'

RSpec.describe ComparativeTableauImage do
  context "with one constraint" do
    let(:clist){double('clist')}
    let(:pref_image_class){double('pref_image_class')}
    before(:each) do
    end
    context "with one erc" do
      let(:erc1){double('erc1')}
      let(:winner1){double('winner1')}
      let(:loser1){double('loser1')}
      let(:input1){double('input1')}
      let(:output_w1){double('output_w1')}
      let(:output_l1){double('output_l1')}
      let(:pref_sheet){Sheet.new}
      before(:each) do
        allow(erc1).to receive(:label).and_return('E1')
        allow(erc1).to receive(:winner).and_return(winner1)
        allow(erc1).to receive(:loser).and_return(loser1)
        allow(winner1).to receive(:input).and_return(input1)
        allow(winner1).to receive(:output).and_return(output_w1)
        allow(loser1).to receive(:output).and_return(output_l1)
        allow(input1).to receive(:to_s).and_return("I1")
        allow(output_w1).to receive(:to_s).and_return("W1_output")
        allow(output_l1).to receive(:to_s).and_return("L1_output")
        allow(pref_image_class).to receive(:new).with([erc1],clist).and_return(pref_sheet)
        pref_sheet[1,1] = 'Con1'
        pref_sheet[2,1] = nil
        @ct_image = ComparativeTableauImage.new([erc1], clist,
          pref_image_class: pref_image_class)
      end
      it "has two rows" do
        expect(@ct_image.row_count).to eq 2
      end
      it "has 5 columns" do
        expect(@ct_image.col_count).to eq 5
      end
      it "has column 1 heading 'ERC#'" do
        expect(@ct_image[1,1]).to eq 'ERC#'
      end
      it "has column 2 heading 'Input'" do
        expect(@ct_image[1,2]).to eq 'Input'
      end
      it "has column 3 heading 'Winner'" do
        expect(@ct_image[1,3]).to eq 'Winner'
      end
      it "has column 4 heading 'Loser'" do
        expect(@ct_image[1,4]).to eq 'Loser'
      end
      it "has column 5 heading 'Con1'" do
        expect(@ct_image[1,5]).to eq 'Con1'
      end
      it "has first erc label E1" do
        expect(@ct_image[2,1]).to eq 'E1'
      end
      it "has first erc input I1" do
        expect(@ct_image[2,2]).to eq 'I1'
      end
      it "has first erc winner output W1_output" do
        expect(@ct_image[2,3]).to eq 'W1_output'
      end
      it "has first erc loser output L1_output" do
        expect(@ct_image[2,4]).to eq 'L1_output'
      end
    end
  end
end # RSpec.describe ComparativeTableauImage

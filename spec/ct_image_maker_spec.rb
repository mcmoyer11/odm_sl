# frozen_string_literal: true

# Author: Bruce Tesar

require 'ct_image_maker'
require 'sheet'

RSpec.describe CtImageMaker do
  context 'with one constraint' do
    let(:clist) { double('clist') }
    let(:pref_image_class) { double('pref_image_class') }
    let(:sheet_class) { double('sheet class') }
    let(:sheet) { double('sheet') }
    let(:inner_class) { double('inner_class') }
    before(:example) do
      allow(sheet_class).to receive(:new).and_return(sheet)
      allow(sheet).to receive(:[]=)
      allow(sheet).to receive(:put_range).and_return(inner_class)
      allow(inner_class).to receive(:[]=)
      @ct_image_maker =
        CtImageMaker.new(pref_image_class: pref_image_class,
                         sheet_class: sheet_class)
    end
    context 'with one erc' do
      let(:erc1) { double('erc1') }
      let(:winner1) { double('winner1') }
      let(:loser1) { double('loser1') }
      let(:input1) { double('input1') }
      let(:output_w1) { double('output_w1') }
      let(:output_l1) { double('output_l1') }
      let(:pref_sheet) { double('pref_sheet') }
      before(:each) do
        allow(erc1).to receive(:label).and_return('E1')
        allow(erc1).to receive(:winner).and_return(winner1)
        allow(erc1).to receive(:loser).and_return(loser1)
        allow(winner1).to receive(:input).and_return(input1)
        allow(winner1).to receive(:output).and_return(output_w1)
        allow(loser1).to receive(:output).and_return(output_l1)
        allow(input1).to receive(:to_s).and_return('I1')
        allow(output_w1).to receive(:to_s).and_return('W1_output')
        allow(output_l1).to receive(:to_s).and_return('L1_output')
        allow(pref_image_class).to\
          receive(:new).with([erc1], clist).and_return(pref_sheet)
        @ct_image = @ct_image_maker.get_image([erc1], clist)
      end
      it "puts the column heading 'ERC#'" do
        expect(@ct_image).to have_received(:[]=).with(1, 1, 'ERC#')
      end
      it "puts the column heading 'Input'" do
        expect(@ct_image).to have_received(:[]=).with(1, 2, 'Input')
      end
      it "puts the column heading 'Winner'" do
        expect(@ct_image).to have_received(:[]=).with(1, 3, 'Winner')
      end
      it "puts the column heading 'Loser'" do
        expect(@ct_image).to have_received(:[]=).with(1, 4, 'Loser')
      end
      it 'puts the first erc label' do
        expect(@ct_image).to have_received(:[]=).with(2, 1, 'E1')
      end
      it 'puts the first erc input' do
        expect(@ct_image).to have_received(:[]=).with(2, 2, 'I1')
      end
      it 'puts the first erc winner output' do
        expect(@ct_image).to have_received(:[]=).with(2, 3, 'W1_output')
      end
      it 'puts the first erc loser output' do
        expect(@ct_image).to have_received(:[]=).with(2, 4, 'L1_output')
      end
      it 'puts the constraint preference image' do
        expect(sheet).to have_received(:put_range).exactly(1).times
      end
    end
  end
end

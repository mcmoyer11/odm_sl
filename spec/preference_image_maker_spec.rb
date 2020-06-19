# frozen_string_literal: true

# Author: Bruce Tesar

require 'preference_image_maker'

RSpec.describe PreferenceImageMaker do
  context 'with 2 constraints' do
    let(:con1) { double('con1') }
    let(:con2) { double('con2') }
    let(:sheet_class) { double('sheet_class') }
    let(:sheet) { double('sheet') }
    before(:example) do
      allow(con1).to receive(:to_s).and_return('con1')
      allow(con2).to receive(:to_s).and_return('con2')
      allow(sheet_class).to receive(:new).and_return(sheet)
      allow(sheet).to receive(:[]=)
      @preference_image_maker =
        PreferenceImageMaker.new(sheet_class: sheet_class)
    end
    context 'and 2 ercs' do
      let(:erc1) { double('erc1') }
      let(:erc2) { double('erc2') }
      before(:example) do
        allow(erc1).to receive(:l?).with(con1).and_return(false)
        allow(erc1).to receive(:w?).with(con1).and_return(true)
        allow(erc1).to receive(:l?).with(con2).and_return(true)
        allow(erc1).to receive(:w?).with(con2).and_return(false)
        allow(erc2).to receive(:l?).with(con1).and_return(false)
        allow(erc2).to receive(:w?).with(con1).and_return(false)
        allow(erc2).to receive(:l?).with(con2).and_return(false)
        allow(erc2).to receive(:w?).with(con2).and_return(true)
        @pref_image =
          @preference_image_maker.get_image([erc1, erc2], [con1, con2])
      end
      it "has col 1 heading 'con1'" do
        expect(@pref_image).to have_received(:[]=).with(1, 1, 'con1')
      end
      it "has col 2 heading 'con2'" do
        expect(@pref_image).to have_received(:[]=).with(1, 2, 'con2')
      end
      it 'has erc1 con1 preference W' do
        expect(@pref_image).to have_received(:[]=).with(2, 1, 'W')
      end
      it 'has erc1 con2 preference L' do
        expect(@pref_image).to have_received(:[]=).with(2, 2, 'L')
      end
      it 'has erc2 con1 preference e' do
        expect(@pref_image).to have_received(:[]=).with(3, 1, nil)
      end
      it 'has erc2 con2 preference W' do
        expect(@pref_image).to have_received(:[]=).with(3, 2, 'W')
      end
    end
    context 'and no ercs' do
      before(:example) do
        @pref_image = @preference_image_maker.get_image([], [con1, con2])
      end
      it "has col 1 heading 'con1'" do
        expect(@pref_image).to have_received(:[]=).with(1, 1, 'con1')
      end
      it "has col 2 heading 'con2'" do
        expect(@pref_image).to have_received(:[]=).with(1, 2, 'con2')
      end
    end
    context 'with no constraints and no ercs' do
      before(:example) do
        @pref_image = @preference_image_maker.get_image([], [])
      end
      it 'writes nothing to the sheet' do
        expect(@pref_image).not_to have_received(:[]=)
      end
    end
  end
end

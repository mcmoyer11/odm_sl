# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/grammar_test_image_maker'

RSpec.describe 'OTLearn::GrammarTestImageMaker' do
  let(:grammar_test) { double('grammar_test') }
  let(:grammar) { double('grammar') }
  let(:erc_list) { double('erc_list') }
  let(:lexicon) { double('lexicon') }
  let(:rcd_runner) { double('rcd_runner') }
  let(:rcd_result) { double('rcd_result') }
  let(:rcd_image_maker) { double('rcd_image_maker') }
  let(:rcd_image) { double('rcd_image') }
  let(:lexicon_image_maker) { double('lexicon_image_maker') }
  let(:lex_image) { double('lex_image') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  context 'given a GrammarTest' do
    before(:each) do
      allow(grammar_test).to receive(:grammar).and_return(grammar)
      allow(grammar).to receive(:erc_list).and_return(erc_list)
      allow(grammar).to receive(:lexicon).and_return(lexicon)
      allow(rcd_runner).to receive(:run_rcd).and_return(rcd_result)
      allow(rcd_image_maker).to receive(:get_image).and_return(rcd_image)
      allow(lexicon_image_maker).to receive(:get_image).and_return(lex_image)
      allow(sheet_class).to receive(:new).and_return(sheet)
      allow(sheet).to receive(:put_range)
      allow(sheet).to receive(:add_empty_row)
      allow(sheet).to receive(:append)
      @gt_image_maker =
        OTLearn::GrammarTestImageMaker\
        .new(rcd_runner: rcd_runner,
             rcd_image_maker: rcd_image_maker,
             lexicon_image_maker: lexicon_image_maker,
             sheet_class: sheet_class)
      @gt_image = @gt_image_maker.get_image(grammar_test)
    end
    it 'adds the RCD image' do
      expect(@gt_image).to have_received(:put_range)\
        .with(1, 2, rcd_image)
    end
    it 'has a blank line after the RCD image' do
      expect(@gt_image).to have_received(:add_empty_row)
    end
    it 'adds the lexicon image' do
      expect(@gt_image).to have_received(:append)\
        .with(lex_image, { start_col: 2 })
    end
  end
end

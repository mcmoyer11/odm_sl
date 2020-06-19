# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/mmr_image_maker'

RSpec.describe OTLearn::MmrImageMaker do
  let(:mmr_step) { double('mmr_step') }
  let(:failed_winner) { double('failed_winner') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  let(:subsheet) { double('subsheet') }
  before(:example) do
    allow(sheet_class).to receive(:new).and_return(sheet, subsheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:append)
    allow(subsheet).to receive(:[]=)
    @mmr_image_maker = OTLearn::MmrImageMaker.new(sheet_class: sheet_class)
  end
  context 'given an MMR step with one failing winner adopted' do
    let(:failed_winner_morphword) { 'failed_winner_morphword' }
    let(:failed_winner_input) { 'failed_winner_input' }
    let(:failed_winner_output) { 'failed_winner_output' }
    before(:each) do
      allow(mmr_step).to receive(:changed?).and_return(true)
      allow(mmr_step).to receive(:failed_winner).and_return(failed_winner)
      allow(failed_winner).to\
        receive(:morphword).and_return(failed_winner_morphword)
      allow(failed_winner).to receive(:input).and_return(failed_winner_input)
      allow(failed_winner).to receive(:output).and_return(failed_winner_output)
      @mmr_image = @mmr_image_maker.get_image(mmr_step)
    end
    it 'indicates the type of substep' do
      expect(@mmr_image).to\
        have_received(:[]=).with(1, 1, 'Max Mismatch Ranking')
    end
    it 'indicates that MMR changed the grammar' do
      expect(@mmr_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: TRUE')
    end
    it 'appends the subsheet' do
      expect(@mmr_image).to have_received(:append).with(subsheet)
    end
    it 'indicates the morphword of the failed winner used' do
      expect(subsheet).to\
        have_received(:[]=).with(1, 3, failed_winner_morphword)
    end
    it 'indicates the input of the failed winner used' do
      expect(subsheet).to\
        have_received(:[]=).with(1, 4, failed_winner_input)
    end
    it 'indicates the output of the failed winner used' do
      expect(subsheet).to\
        have_received(:[]=).with(1, 5, failed_winner_output)
    end
  end

  context 'given an MMR step without a newly set feature' do
    before(:each) do
      allow(mmr_step).to receive(:changed?).and_return(false)
      @mmr_image = @mmr_image_maker.get_image(mmr_step)
    end
    it 'indicates the type of substep' do
      expect(@mmr_image).to\
        have_received(:[]=).with(1, 1, 'Max Mismatch Ranking')
    end
    it 'indicates the MMR did not change the grammar' do
      expect(@mmr_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: FALSE')
    end
    it 'does not append a subsheet' do
      expect(@mmr_image).not_to have_received(:append).with(subsheet)
    end
  end
end

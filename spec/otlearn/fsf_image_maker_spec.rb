# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/fsf_image_maker'

RSpec.describe OTLearn::FsfImageMaker do
  let(:fsf_step) { double('fsf_step') }
  let(:failed_winner) { double('failed_winner') }
  let(:failed_winner_morphword) { 'failed_winner_morphword' }
  let(:failed_winner_input) { 'failed_winner_input' }
  let(:failed_winner_output) { 'failed_winner_output' }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  let(:subsheet) { double('subsheet') }
  before(:each) do
    allow(fsf_step).to receive(:failed_winner).and_return(failed_winner)
    allow(failed_winner).to\
      receive(:morphword).and_return(failed_winner_morphword)
    allow(failed_winner).to receive(:input).and_return(failed_winner_input)
    allow(failed_winner).to receive(:output).and_return(failed_winner_output)
    allow(sheet_class).to receive(:new).and_return(sheet, subsheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:append)
    allow(subsheet).to receive(:[]=)
    @fsf_image_maker = OTLearn::FsfImageMaker.new(sheet_class: sheet_class)
  end
  context 'given a step with a newly set feature' do
    before(:each) do
      allow(fsf_step).to receive(:changed?).and_return(true)
      @fsf_image = @fsf_image_maker.get_image(fsf_step)
    end
    it 'indicates the type of substep' do
      expect(@fsf_image).to\
        have_received(:[]=).with(1, 1, 'Fewest Set Features')
    end
    it 'indicates that FSF changed the grammar' do
      expect(@fsf_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: TRUE')
    end
    it 'appends the subsheet' do
      expect(@fsf_image).to have_received(:append).with(subsheet)
    end
    it 'indicates the failed winner morphword on the subsheet' do
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

  context 'given a step without a newly set feature' do
    before(:each) do
      allow(fsf_step).to receive(:changed?).and_return(false)
      @fsf_image = @fsf_image_maker.get_image(fsf_step)
    end
    it 'indicates the type of substep' do
      expect(@fsf_image).to\
        have_received(:[]=).with(1, 1, 'Fewest Set Features')
    end
    it 'indicates the FSF did not change the grammar' do
      expect(@fsf_image).to\
        have_received(:[]=).with(2, 1, 'Grammar Changed: FALSE')
    end
    it 'appends the subsheet' do
      expect(@fsf_image).to have_received(:append).with(subsheet)
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
end

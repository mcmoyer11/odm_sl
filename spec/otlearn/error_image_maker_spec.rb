# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/error_image_maker'

RSpec.describe 'OTLearn::ErrorImageMaker' do
  let(:err_step) { double('error step') }
  let(:sheet_class) { double('sheet class') }
  let(:sheet) { double('sheet') }
  before(:example) do
    allow(err_step).to receive(:msg).and_return('the error message')
    allow(sheet_class).to receive(:new).and_return(sheet)
    allow(sheet).to receive(:[]=)
    @error_image_maker =
      OTLearn::ErrorImageMaker.new(sheet_class: sheet_class)
  end

  context 'given an error step' do
    before(:example) do
      @error_image = @error_image_maker.get_image(err_step)
    end
    it 'writes the image header to the sheet' do
      expect(@error_image).to\
        have_received(:[]=).with(1, 1, 'ERROR: learning terminated')
    end
    it 'writes the step message to the sheet' do
      expect(@error_image).to\
        have_received(:[]=).with(1, 2, 'the error message')
    end
  end
end

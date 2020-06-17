# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/single_form_learning_image_maker'

# HOW THIS WORKS: a test double of the Sheet class is passed in as
# a dependency injection. The sheet_class double responds to .new
# by returning a sheet object test double. The sheet object test double
# acts as a test spy, and it should be the return value for the method
# #get_image. Expectations are then made of the returned value of
# #get_image, stored in @sf_image. It is expected to have received
# messages writing values to the sheet.
RSpec.describe OTLearn::SingleFormLearningImageMaker do
  let(:sf_step) { double('sf learning step') }
  let(:grammar_test_image_maker) { double('grammar_test_image_maker') }
  let(:test_result) { double('test_result') }
  let(:test_image) { double('test_image') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  before(:each) do
    allow(grammar_test_image_maker).to\
      receive(:get_image).with(test_result).and_return(test_image)
    allow(sf_step).to receive(:test_result).and_return(test_result)
    allow(sheet_class).to receive(:new).and_return(sheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:append)
    @sf_image_maker =
      OTLearn::SingleFormLearningImageMaker\
      .new(grammar_test_image_maker: grammar_test_image_maker,
           sheet_class: sheet_class)
  end

  context 'given a single form learning step' do
    before(:each) do
      @sf_image = @sf_image_maker.get_image(sf_step)
    end
    it 'indicates the step type' do
      expect(@sf_image).to\
        have_received(:[]=).with(1, 1, 'Single Form Learning')
    end
    it 'adds the test result image' do
      expect(@sf_image).to have_received(:append).with(test_image)
    end
  end
end

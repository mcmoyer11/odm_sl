# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/induction_learning_image_maker'
require 'otlearn/induction_learning'

# HOW THIS WORKS: a test double of the Sheet class is passed in as
# a dependency injection. The sheet_class double responds to .new
# by returning a sheet object test double. The sheet object test double
# acts as a test spy, and it should be the return value for the method
# #get_image. Expectations are then made of the returned value of
# #get_image, stored in @in_image. It is expected to have received
# messages writing values to the sheet.
RSpec.describe OTLearn::InductionLearningImageMaker do
  let(:in_step) { double('in_step') }
  let(:fsf_image_maker) { double('fsf_image_maker') }
  let(:fsf_image) { double('fsf_image') }
  let(:mmr_image_maker) { double('mmr_image_maker') }
  let(:mmr_image) { double('mmr_image') }
  let(:grammar_test_image_maker) { double('grammar_test_image_maker') }
  let(:test_result) { double('test_result') }
  let(:test_image) { double('test_image') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  before(:each) do
    allow(grammar_test_image_maker).to\
      receive(:get_image).with(test_result).and_return(test_image)
    allow(in_step).to receive(:test_result).and_return(test_result)
    allow(fsf_image_maker).to\
      receive(:get_image).and_return(fsf_image)
    allow(mmr_image_maker).to\
      receive(:get_image).and_return(mmr_image)
    allow(sheet_class).to receive(:new).and_return(sheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:add_empty_row)
    allow(sheet).to receive(:append)
    @in_image_maker =
      OTLearn::InductionLearningImageMaker\
      .new(grammar_test_image_maker: grammar_test_image_maker,
           fsf_image_maker: fsf_image_maker,
           mmr_image_maker: mmr_image_maker,
           sheet_class: sheet_class)
  end

  context 'given a step with fewest set features' do
    let(:step_subtype) { OTLearn::InductionLearning::FEWEST_SET_FEATURES }
    before(:each) do
      allow(in_step).to\
        receive(:step_subtype).and_return(step_subtype)
      allow(in_step).to receive(:fsf_step)
      @in_image = @in_image_maker.get_image(in_step)
    end
    it 'indicates the step type' do
      expect(@in_image).to\
        have_received(:[]=).with(1, 1, 'Induction Learning')
    end
    it 'creates an FSF image' do
      expect(fsf_image_maker).to have_received(:get_image)
    end
    it 'does not create an MMR image' do
      expect(mmr_image_maker).not_to have_received(:get_image)
    end
    it 'adds the FSF image' do
      expect(@in_image).to have_received(:append).with(fsf_image)
    end
    it 'adds the test image' do
      expect(@in_image).to have_received(:append).with(test_image)
    end
  end

  context 'given a step with max mismatch ranking' do
    let(:step_subtype) { OTLearn::InductionLearning::MAX_MISMATCH_RANKING }
    before(:each) do
      allow(in_step).to\
        receive(:step_subtype).and_return(step_subtype)
      allow(in_step).to receive(:mmr_step)
      @in_image = @in_image_maker.get_image(in_step)
    end
    it 'indicates the step type' do
      expect(@in_image).to\
        have_received(:[]=).with(1, 1, 'Induction Learning')
    end
    it 'does not create an FSF image' do
      expect(fsf_image_maker).not_to have_received(:get_image)
    end
    it 'creates an MMR image' do
      expect(mmr_image_maker).to have_received(:get_image)
    end
    it 'adds the MMR image' do
      expect(@in_image).to have_received(:append).with(mmr_image)
    end
    it 'adds the test image' do
      expect(@in_image).to have_received(:append).with(test_image)
    end
  end
end

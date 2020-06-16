# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/contrast_pair_learning_image_maker'

RSpec.describe OTLearn::ContrastPairLearningImageMaker do
  let(:cp_step) { double('cp_step') }
  let(:grammar_test_image_class) { double('grammar_test_image_class') }
  let(:test_result) { double('test_result') }
  let(:test_image) { double('test_image') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  before(:each) do
    allow(grammar_test_image_class).to\
      receive(:new).with(test_result).and_return(test_image)
    allow(cp_step).to receive(:test_result).and_return(test_result)
    allow(sheet_class).to receive(:new).and_return(sheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:append)
    @cp_image_maker =
      OTLearn::ContrastPairLearningImageMaker\
      .new(grammar_test_image_class: grammar_test_image_class,
           sheet_class: sheet_class)
  end

  context 'given a successful contrast pair learning step' do
    let(:word1) { double('word1') }
    let(:word2) { double('word2') }
    let(:contrast_pair) { [word1, word2] }
    before(:each) do
      allow(cp_step).to receive(:changed?).and_return(true)
      allow(cp_step).to receive(:contrast_pair).and_return(contrast_pair)
      allow(word1).to receive(:morphword).and_return('mw1')
      allow(word1).to receive(:input).and_return('in1')
      allow(word1).to receive(:output).and_return('out1')
      allow(word2).to receive(:morphword).and_return('mw2')
      allow(word2).to receive(:input).and_return('in2')
      allow(word2).to receive(:output).and_return('out2')
      @cp_image = @cp_image_maker.get_image(cp_step)
    end
    it 'indicates the step type' do
      expect(@cp_image).to\
        have_received(:[]=).with(1, 1, 'Contrast Pair Learning')
    end
    it 'indicates the contrast pair heading' do
      expect(@cp_image).to\
        have_received(:[]=).with(2, 2, 'Contrast Pair:')
    end
    it 'indicates the first CP word' do
      expect(@cp_image).to\
        have_received(:[]=).with(2, 3, 'mw1 in1->out1')
    end
    it 'indicates the second CP word' do
      expect(@cp_image).to\
        have_received(:[]=).with(2, 4, 'mw2 in2->out2')
    end
    it 'constructs a grammar test image' do
      expect(grammar_test_image_class).to have_received(:new)
    end
    it 'adds the test result image' do
      expect(@cp_image).to have_received(:append).with(test_image)
    end
  end

  context 'given an unsuccessful contrast pair learning step' do
    before(:each) do
      allow(cp_step).to receive(:changed?).and_return(false)
      allow(cp_step).to receive(:contrast_pair).and_return(nil)
      @cp_image = @cp_image_maker.get_image(cp_step)
    end
    it 'indicates the step type' do
      expect(@cp_image).to\
        have_received(:[]=).with(1, 1, 'Contrast Pair Learning')
    end
    it 'indicates that no contrast pair was found' do
      expect(@cp_image).to\
        have_received(:[]=).with(2, 2, 'None Found')
    end
    it 'does not construct a grammar test image' do
      expect(grammar_test_image_class).not_to have_received(:new)
    end
    it 'does not add a test result image' do
      expect(@cp_image).not_to have_received(:append).with(test_image)
    end
  end
end

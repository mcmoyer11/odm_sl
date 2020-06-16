# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/language_learning_image_maker'
require 'otlearn/language_learning'

RSpec.describe OTLearn::LanguageLearningImageMaker do
  let(:language_learning) { double('language_learning') }
  let(:grammar) { double('grammar') }
  let(:grammar_label) { double('grammar_label') }
  let(:phonotactic_image_class) { double('phonotactic_image_class') }
  let(:single_form_image_class) { double('single_form_image_class') }
  let(:contrast_pair_image_class) { double('contrast_pair_image_class') }
  let(:induction_image_class) { double('induction_image_class') }
  let(:sheet_class) { double('sheet_class') }
  let(:sheet) { double('sheet') }
  before(:each) do
    allow(language_learning).to receive(:learning_successful?)\
      .and_return('success_value')
    allow(language_learning).to receive(:grammar).and_return(grammar)
    allow(grammar).to receive(:label).and_return(grammar_label)
    allow(sheet_class).to receive(:new).and_return(sheet)
    allow(sheet).to receive(:[]=)
    allow(sheet).to receive(:add_empty_row)
    allow(sheet).to receive(:append)
    @ll_image_object =
      OTLearn::LanguageLearningImageMaker.new(sheet_class: sheet_class)
  end
  context 'with one phonotactic step' do
    let(:result_ph) { double('phonotactic result') }
    let(:step_ph) { double('phonotactic step') }
    let(:step_list) { [step_ph] }
    let(:image_ph) { double('ph image') }
    before(:each) do
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step_ph).to receive(:step_type).and_return(OTLearn::PHONOTACTIC)
      allow(phonotactic_image_class).to\
        receive(:new).with(step_ph).and_return(image_ph)
      @ll_image_object.set_image_maker(OTLearn::PHONOTACTIC,
                                       phonotactic_image_class)
      @ll_image = @ll_image_object.get_image(language_learning)
    end
    it 'adds the grammar label' do
      expect(@ll_image).to have_received(:[]=).with(1, 1, grammar_label)
    end
    it 'indicates the learning success value' do
      expect(@ll_image).to\
        have_received(:[]=).with(2, 1, 'Learned: success_value')
    end
    it 'creates a phonotactic image' do
      expect(phonotactic_image_class).to have_received(:new).with(step_ph)
    end
    it 'adds the result image' do
      expect(@ll_image).to have_received(:append).with(image_ph)
    end
  end
  context 'with a phonotactic step and a single form step' do
    let(:result_ph) { double('phonotactic result') }
    let(:result_sf) { double('single form result') }
    let(:step_ph) { double('phonotactic step') }
    let(:step_sf) { double('single form step') }
    let(:step_list) { [step_ph, step_sf] }
    let(:image_ph) { double('ph image') }
    let(:image_sf) { double('sf image') }
    before(:each) do
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step_ph).to receive(:step_type).and_return(OTLearn::PHONOTACTIC)
      allow(step_sf).to receive(:step_type).and_return(OTLearn::SINGLE_FORM)
      allow(phonotactic_image_class).to receive(:new).and_return(image_ph)
      allow(single_form_image_class).to receive(:new).and_return(image_sf)
      @ll_image_object.set_image_maker(OTLearn::PHONOTACTIC,
                                       phonotactic_image_class)
      @ll_image_object.set_image_maker(OTLearn::SINGLE_FORM,
                                       single_form_image_class)
      @ll_image = @ll_image_object.get_image(language_learning)
    end
    it 'adds the grammar label' do
      expect(@ll_image).to have_received(:[]=).with(1, 1, grammar_label)
    end
    it 'indicates the learning success value' do
      expect(@ll_image).to\
        have_received(:[]=).with(2, 1, 'Learned: success_value')
    end
    it 'creates a phonotactic step image' do
      expect(phonotactic_image_class).to\
        have_received(:new).with(step_ph).exactly(1).times
    end
    it 'creates a single form step image' do
      expect(single_form_image_class).to\
        have_received(:new).with(step_sf).exactly(1).times
    end
    it 'adds the phonotactic image' do
      expect(@ll_image).to have_received(:append).with(image_ph)
    end
    it 'adds the single form image' do
      expect(@ll_image).to have_received(:append).with(image_sf)
    end
  end

  context 'with one induction learning step' do
    let(:result_in) { double('induction result') }
    let(:step_in) { double('induction step') }
    let(:step_list) { [step_in] }
    let(:image_in) { double('induction image') }
    before(:each) do
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step_in).to receive(:step_type).and_return(OTLearn::INDUCTION)
      allow(induction_image_class).to\
        receive(:new).with(step_in).and_return(image_in)
      @ll_image_object.set_image_maker(OTLearn::INDUCTION,
                                       induction_image_class)
      @ll_image = @ll_image_object.get_image(language_learning)
    end
    it 'adds the grammar label' do
      expect(@ll_image).to have_received(:[]=).with(1, 1, grammar_label)
    end
    it 'indicates the learning success value' do
      expect(@ll_image).to\
        have_received(:[]=).with(2, 1, 'Learned: success_value')
    end
    it 'creates an image for the induction learning step' do
      expect(induction_image_class).to have_received(:new).with(step_in)
    end
    it 'adds the induction step image' do
      expect(@ll_image).to have_received(:append).with(image_in)
    end
  end
  context 'with one unrecognized learning step' do
    let(:result_ur) { double('unrecognized result') }
    let(:step_ur) { double('unrecognized step') }
    let(:step_list) { [step_ur] }
    before(:each) do
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step_ur).to receive(:step_type).and_return(:unrecognized_step_type)
      allow(step_ur).to receive(:test_result).and_return(result_ur)
    end
    it 'raises a RuntimeError' do
      expect { @ll_image_object.get_image(language_learning) }.to\
        raise_error RuntimeError
    end
  end
end

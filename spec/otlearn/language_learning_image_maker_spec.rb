# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/language_learning_image_maker'
require 'otlearn/language_learning'

RSpec.describe OTLearn::LanguageLearningImageMaker do
  let(:language_learning) { double('language_learning') }
  let(:grammar) { double('grammar') }
  let(:grammar_label) { double('grammar_label') }
  let(:phonotactic_image_class) { double('phonotactic_image_class') }
  let(:phonotactic_step_type) { OTLearn::LanguageLearning::PHONOTACTIC }
  let(:single_form_image_class) { double('single_form_image_class') }
  let(:single_form_step_type) { OTLearn::LanguageLearning::SINGLE_FORM }
  let(:contrast_pair_step_image_class) { double('contrast_pair_step_image_class') }
  let(:contrast_pair_step_type) { OTLearn::LanguageLearning::CONTRAST_PAIR }
  let(:induction_image_class) { double('induction_image_class') }
  let(:induction_step_type) { OTLearn::LanguageLearning::INDUCTION }
  before(:each) do
    allow(language_learning).to receive(:learning_successful?)\
      .and_return('success_value')
    allow(language_learning).to receive(:grammar).and_return(grammar)
    allow(grammar).to receive(:label).and_return(grammar_label)
    @ll_image_object = OTLearn::LanguageLearningImageMaker.new
  end
  context 'with one phonotactic step' do
    let(:result_ph) { double('phonotactic result') }
    let(:step_ph) { double('phonotactic step') }
    let(:step_list) { [step_ph] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'result_ph'; s }
    before(:each) do
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step_ph).to receive(:step_type).and_return(phonotactic_step_type)
      allow(phonotactic_image_class).to\
        receive(:new).with(step_ph).and_return(result_image1)
      @ll_image_object.set_image_maker(phonotactic_step_type,
                                       phonotactic_image_class)
      @ll_image = @ll_image_object.get_image(language_learning)
    end
    it 'adds the grammar label' do
      expect(@ll_image[1, 1]).to eq grammar_label
    end
    it 'indicates the learning success value' do
      expect(@ll_image[2, 1]).to eq 'Learned: success_value'
    end
    it 'creates a phonotactic image' do
      expect(phonotactic_image_class).to have_received(:new).with(step_ph)
    end
    it 'adds the result image' do
      expect(@ll_image[4, 1]).to eq 'result_ph'
    end
  end
  context 'with a phonotactic step and a single form step' do
    let(:result_ph) { double('phonotactic result') }
    let(:result_sf) { double('single form result') }
    let(:step_ph) { double('phonotactic step') }
    let(:step_sf) { double('single form step') }
    let(:step_list) { [step_ph, step_sf] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'PhonotacticImage1'; s }
    let(:result_image2) { s = Sheet.new; s[1, 1] = 'SingleFormImage2'; s }
    before(:each) do
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step_ph).to receive(:step_type).and_return(phonotactic_step_type)
      allow(step_sf).to receive(:step_type).and_return(single_form_step_type)
      allow(phonotactic_image_class).to receive(:new).and_return(result_image1)
      allow(single_form_image_class).to receive(:new).and_return(result_image2)
      @ll_image_object.set_image_maker(phonotactic_step_type,
                                       phonotactic_image_class)
      @ll_image_object.set_image_maker(single_form_step_type,
                                       single_form_image_class)
      @ll_image = @ll_image_object.get_image(language_learning)
    end
    it 'adds the grammar label' do
      expect(@ll_image[1, 1]).to eq grammar_label
    end
    it 'indicates the learning success value' do
      expect(@ll_image[2, 1]).to eq 'Learned: success_value'
    end
    it 'creates a phonotactic step image' do
      expect(phonotactic_image_class).to\
        have_received(:new).with(step_ph).exactly(1).times
    end
    it 'creates a single form step image' do
      expect(single_form_image_class).to\
        have_received(:new).with(step_sf).exactly(1).times
    end
    it 'adds the first result image' do
      expect(@ll_image[4, 1]).to eq 'PhonotacticImage1'
    end
    it 'adds the second result image' do
      expect(@ll_image[6, 1]).to eq 'SingleFormImage2'
    end
  end

  context 'with one induction learning step' do
    let(:result_in) { double('induction result') }
    let(:step_in) { double('induction step') }
    let(:step_list) { [step_in] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'result_in'; s }
    let(:induction_image) { s = Sheet.new; s[1, 1] = 'Induction Image'; s }
    before(:each) do
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step_in).to receive(:step_type).and_return(induction_step_type)
      allow(induction_image_class).to\
        receive(:new).with(step_in).and_return(induction_image)
      @ll_image_object.set_image_maker(induction_step_type,
                                       induction_image_class)
      @ll_image = @ll_image_object.get_image(language_learning)
    end
    it 'adds the grammar label' do
      expect(@ll_image[1, 1]).to eq grammar_label
    end
    it 'indicates the learning success value' do
      expect(@ll_image[2, 1]).to eq 'Learned: success_value'
    end
    it 'creates an image for the induction learning step' do
      expect(induction_image_class).to have_received(:new).with(step_in)
    end
    it 'adds the induction step image' do
      expect(@ll_image[4, 1]).to eq 'Induction Image'
    end
  end
  context 'with one unrecognized learning step' do
    let(:result_ur) { double('unrecognized result') }
    let(:step_ur) { double('unrecognized step') }
    let(:step_list) { [step_ur] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'result_ur'; s }
    let(:induction_image) { s = Sheet.new; s[1, 1] = 'Unrecognized Image'; s }
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

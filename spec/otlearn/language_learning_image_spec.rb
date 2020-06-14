# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/language_learning_image'
require 'otlearn/language_learning'

RSpec.describe OTLearn::LanguageLearningImage do
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
  let(:grammar_test_image_class) { double('grammar_test_image_class') }
  before(:each) do
    allow(language_learning).to receive(:grammar).and_return(grammar)
    allow(grammar).to receive(:label).and_return(grammar_label)
  end
  context 'with one result' do
    let(:result1) { double('result1') }
    let(:step1) { double('step1') }
    let(:step_list) { [step1] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'result1'; s }
    before(:each) do
      allow(language_learning).to receive(:learning_successful?).and_return(true)
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step1).to receive(:step_type).and_return(:test_type)
      allow(step1).to receive(:test_result).and_return(result1)
      allow(grammar_test_image_class).to \
        receive(:new).with(result1).and_return(result_image1)
      @ll_image =
        OTLearn::LanguageLearningImage.new(language_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it 'adds the grammar label' do
      expect(@ll_image[1, 1]).to eq grammar_label
    end
    it 'indicates that learning succeeded' do
      expect(@ll_image[2, 1]).to eq 'Learned: true'
    end
    it 'creates an image for the result' do
      expect(grammar_test_image_class).to have_received(:new).with(result1)
    end
    it 'adds the result image' do
      expect(@ll_image[4, 1]).to eq 'result1'
    end
  end

  context 'with two results' do
    let(:result1) { double('result1') }
    let(:result2) { double('result2') }
    let(:step1) { double('step1') }
    let(:step2) { double('step2') }
    let(:step_list) { [step1, step2] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'result1'; s }
    let(:result_image2) { s = Sheet.new; s[1, 1] = 'result2'; s }
    before(:each) do
      allow(language_learning).to receive(:learning_successful?).and_return(true)
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step1).to receive(:test_result).and_return(result1)
      allow(step1).to receive(:step_type).and_return(:test_type)
      allow(step2).to receive(:test_result).and_return(result2)
      allow(step2).to receive(:step_type).and_return(:test_type)
      allow(grammar_test_image_class).to \
        receive(:new).and_return(result_image1, result_image2)
      @ll_image =
        OTLearn::LanguageLearningImage.new(language_learning,
        grammar_test_image_class: grammar_test_image_class)
    end
    it 'adds the grammar label' do
      expect(@ll_image[1, 1]).to eq grammar_label
    end
    it 'indicates that learning succeeded' do
      expect(@ll_image[2, 1]).to eq 'Learned: true'
    end
    it 'creates an image for each result' do
      expect(grammar_test_image_class).to have_received(:new).exactly(2).times
    end
    it 'adds the first result image' do
      expect(@ll_image[4, 1]).to eq 'result1'
    end
    it 'adds the second result image' do
      expect(@ll_image[6, 1]).to eq 'result2'
    end
  end

  context 'with a phonotactic result and a single form result' do
    let(:result1) { double('result1') }
    let(:result2) { double('result2') }
    let(:step1) { double('step1') }
    let(:step2) { double('step2') }
    let(:step_list) { [step1, step2] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'PhonotacticImage1'; s }
    let(:result_image2) { s = Sheet.new; s[1, 1] = 'SingleFormImage2'; s }
    before(:each) do
      allow(language_learning).to receive(:learning_successful?).and_return(true)
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step1).to receive(:test_result).and_return(result1)
      allow(step1).to receive(:step_type).and_return(phonotactic_step_type)
      allow(step2).to receive(:test_result).and_return(result2)
      allow(step2).to receive(:step_type).and_return(single_form_step_type)
      allow(grammar_test_image_class).to \
        receive(:new).and_return(result_image1, result_image2)
      allow(phonotactic_image_class).to receive(:new).and_return(result_image1)
      allow(single_form_image_class).to receive(:new).and_return(result_image2)
      @ll_image =
        OTLearn::LanguageLearningImage.new(language_learning,
        phonotactic_image_class: phonotactic_image_class,
        single_form_image_class: single_form_image_class,
        grammar_test_image_class: grammar_test_image_class)
    end
    it 'adds the grammar label' do
      expect(@ll_image[1, 1]).to eq grammar_label
    end
    it 'indicates that learning succeeded' do
      expect(@ll_image[2, 1]).to eq 'Learned: true'
    end
    it 'creates a phonotactic step image' do
      expect(phonotactic_image_class).to have_received(:new).with(step1).exactly(1).times
    end
    it 'creates a single form step image' do
      expect(single_form_image_class).to have_received(:new).with(step2).exactly(1).times
    end
    it 'adds the first result image' do
      expect(@ll_image[4, 1]).to eq 'PhonotacticImage1'
    end
    it 'adds the second result image' do
      expect(@ll_image[6, 1]).to eq 'SingleFormImage2'
    end
  end

  context 'with one induction learning step' do
    let(:result1) { double('result1') }
    let(:step1) { double('step1') }
    let(:step_list) { [step1] }
    let(:result_image1) { s = Sheet.new; s[1, 1] = 'result1'; s }
    let(:induction_image) { s = Sheet.new; s[1, 1] = 'Induction Image'; s }
    before(:each) do
      allow(language_learning).to receive(:learning_successful?).and_return(true)
      allow(language_learning).to receive(:step_list).and_return(step_list)
      allow(step1).to receive(:step_type).and_return(OTLearn::LanguageLearning::INDUCTION)
      allow(step1).to receive(:test_result).and_return(result1)
      allow(induction_image_class).to \
        receive(:new).with(step1).and_return(induction_image)
      allow(grammar_test_image_class).to \
        receive(:new).with(result1).and_return(result_image1)
      @ll_image =
        OTLearn::LanguageLearningImage.new(language_learning,
        induction_image_class: induction_image_class,
        grammar_test_image_class: grammar_test_image_class)
    end
    it 'adds the grammar label' do
      expect(@ll_image[1, 1]).to eq grammar_label
    end
    it 'indicates that learning succeeded' do
      expect(@ll_image[2, 1]).to eq 'Learned: true'
    end
    it 'creates an image for the induction learning step' do
      expect(induction_image_class).to have_received(:new).with(step1)
    end
    it 'adds the induction step image' do
      expect(@ll_image[4, 1]).to eq 'Induction Image'
    end
  end
end

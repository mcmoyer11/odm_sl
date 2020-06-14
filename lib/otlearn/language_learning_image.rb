# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/phonotactic_learning_image'
require 'otlearn/single_form_learning_image'
require 'otlearn/contrast_pair_learning_image'
require 'otlearn/induction_learning_image'
require 'otlearn/grammar_test_image'
require 'otlearn/language_learning'

module OTLearn
  # A 2-dimensional sheet representation of a LanguageLearning object,
  # which contains a synopsis of a language learning simulation.
  class LanguageLearningImage
    # Constructs a language learning image from a language learning object.
    #
    # * +grammar_test_image_class+ - the class of object used to represent
    #   a grammar test results for a given point in learning.
    #   Used for testing (dependency injection).
    #
    # :call-seq:
    #   LanguageLearningImage.new -> img
    def initialize(
        phonotactic_image_class: OTLearn::PhonotacticLearningImage,
        single_form_image_class: OTLearn::SingleFormLearningImage,
        contrast_pair_image_class: OTLearn::ContrastPairLearningImage,
        induction_image_class: OTLearn::InductionLearningImage,
        grammar_test_image_class: OTLearn::GrammarTestImage)
      @phonotactic_image_class = phonotactic_image_class
      @single_form_image_class = single_form_image_class
      @contrast_pair_image_class = contrast_pair_image_class
      @induction_image_class = induction_image_class
      @grammar_test_image_class = grammar_test_image_class
    end

    # Returns a sheet containing the image of the learning simulation.
    # :call-seq:
    #   LanguageLearningImage#get_sheet(language_learning) -> sheet
    def get_sheet(language_learning)
      sheet = Sheet.new
      # Put the language label first
      sheet[1, 1] = language_learning.grammar.label
      # Indicate if learning succeeded.
      sheet[2, 1] = "Learned: #{language_learning.learning_successful?}"
      # Add each step result to the sheet
      language_learning.step_list.each do |step|
        step_image = construct_step_image(step)
        sheet.add_empty_row
        sheet.append(step_image)
      end
      sheet
    end

    def construct_step_image(step)
      case step.step_type
      when LanguageLearning::PHONOTACTIC
        step_image = @phonotactic_image_class.new(step)
      when LanguageLearning::SINGLE_FORM
        step_image = @single_form_image_class.new(step)
      when LanguageLearning::CONTRAST_PAIR
        step_image = @contrast_pair_image_class.new(step)
      when LanguageLearning::INDUCTION
        step_image = @induction_image_class.new(step)
      else
        # TODO: should an exception be raised here instead?
        step_image = @grammar_test_image_class.new(step.test_result)
      end
      step_image
    end
    private :construct_step_image
  end
end

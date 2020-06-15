# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/phonotactic_learning_image'
require 'otlearn/single_form_learning_image'
require 'otlearn/contrast_pair_learning_image'
require 'otlearn/induction_learning_image'
require 'otlearn/language_learning'

module OTLearn
  # A 2-dimensional sheet representation of a LanguageLearning object,
  # which contains a synopsis of a language learning simulation.
  class LanguageLearningImageMaker
    # The phonotactic learning step type.
    PHONOTACTIC = LanguageLearning::PHONOTACTIC

    # The single form learning step type.
    SINGLE_FORM = LanguageLearning::SINGLE_FORM

    # The contrast pair learning step type.
    CONTRAST_PAIR = LanguageLearning::CONTRAST_PAIR

    # The induction learning step type.
    INDUCTION = LanguageLearning::INDUCTION

    # Constructs a language learning image from a language learning object.
    # :call-seq:
    #   LanguageLearningImageMaker.new -> image_maker
    def initialize
      @image_makers = {}
      @image_makers[PHONOTACTIC] = OTLearn::PhonotacticLearningImage
      @image_makers[SINGLE_FORM] = OTLearn::SingleFormLearningImage
      @image_makers[CONTRAST_PAIR] = OTLearn::ContrastPairLearningImage
      @image_makers[INDUCTION] = OTLearn::InductionLearningImage
    end

    # Set (change or add) the image maker object for +step_type+.
    def set_image_maker(step_type, maker)
      @image_makers[step_type] = maker
    end

    # Returns a sheet containing the image of the learning simulation.
    # :call-seq:
    #   LanguageLearningImageMaker#get_image(language_learning) -> sheet
    def get_image(language_learning)
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

    # Construct the image for a learning step.
    def construct_step_image(step)
      step_type = step.step_type
      unless @image_makers.key?(step_type)
        raise "LanguageLearningImageMaker: unrecognized step type #{step_type}"
      end

      @image_makers[step_type].new(step)
    end
    private :construct_step_image
  end
end

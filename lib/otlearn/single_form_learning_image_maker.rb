# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/grammar_test_image'

module OTLearn
  # A 2-dimensional sheet representation of a SingleFormLearning object,
  # which contains a synopsis of a single form learning step.
  class SingleFormLearningImageMaker
    # Constructs a single form learning image from a single form learning
    # step.
    #--
    # +grammar_test_image_class+ and +sheet_class+ are dependency injections
    # used for testing.
    #++
    # :call-seq:
    #   SingleFormLearningImageMaker.new -> image_maker
    def initialize(grammar_test_image_class: OTLearn::GrammarTestImage,
                   sheet_class: Sheet)
      @grammar_test_image_class = grammar_test_image_class
      @sheet_class = sheet_class
    end

    # Constructs the image from the single form learning step.
    # Returns a sheet containing the image of the single form learning step.
    # :call-seq:
    #   get_image(sf_step) -> sheet
    def get_image(sf_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Single Form Learning'
      # Construct and add Grammar Test information
      test_image = @grammar_test_image_class.new(sf_step.test_result)
      sheet.append(test_image)
      sheet
    end
  end
end

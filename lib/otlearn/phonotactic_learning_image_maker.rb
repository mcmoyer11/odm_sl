# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/grammar_test_image'

module OTLearn
  # A 2-dimensional sheet representation of a PhonotacticLearning object,
  # which contains a synopsis of a phonotactic learning step.
  class PhonotacticLearningImageMaker
    # Constructs a phonotactic learning image from a phonotactic learning
    # step.
    #--
    # +grammar_test_image_class+ and +sheet_class+ are dependency injections
    # used for testing.
    #++
    # :call-seq:
    #   PhonotacticLearningImageMaker.new -> image_maker
    def initialize(grammar_test_image_class: GrammarTestImage,
                   sheet_class: Sheet)
      @grammar_test_image_class = grammar_test_image_class
      @sheet_class = sheet_class
    end

    # Constructs the image from the phonotactic learning step.
    # Returns a sheet containing the image of the phonotactic learning step.
    # :call-seq:
    #   get_image(ph_step) -> sheet
    def get_image(ph_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Phonotactic Learning'
      # Construct and add Grammar Test information
      test_image = @grammar_test_image_class.new(ph_step.test_result)
      sheet.append(test_image)
      sheet
    end
  end
end

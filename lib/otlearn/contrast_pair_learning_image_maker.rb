# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/grammar_test_image_maker'

module OTLearn
  # A 2-dimensional sheet representation of a ContrastPairLearning object,
  # which contains a synopsis of a contrast pair learning step.
  class ContrastPairLearningImageMaker
    # Constructs a contrast pair learning image from a contrast pair learning
    # step.
    #--
    # +grammar_test_image_maker+ and +sheet_class+ are dependency injections
    # used for testing.
    #++
    # :call-seq:
    #   ContrastPairLearningImageMaker.new -> image_maker
    def initialize(grammar_test_image_maker: GrammarTestImageMaker.new,
                   sheet_class: Sheet)
      @grammar_test_image_maker = grammar_test_image_maker
      @sheet_class = sheet_class
    end

    # Constructs the image from the contrast pair learning step.
    def get_image(cp_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Contrast Pair Learning'
      # Add the contrast pair to the sheet, or indicate that none were found.
      cpair = cp_step.contrast_pair
      if cpair
        sheet[2, 2] = 'Contrast Pair:'
        sheet[2, 3] = word_string_short(cpair[0])
        sheet[2, 4] = word_string_short(cpair[1])
      else
        sheet[2, 2] = 'None Found'
      end
      # If the grammar changes, construct and add Grammar Test info.
      if cp_step.changed?
        test_image = @grammar_test_image_maker.get_image(cp_step.test_result)
        sheet.append(test_image)
      end
      sheet
    end

    # Returns a string representing +word+ that is short, only giving
    # the morphword, input and output.
    def word_string_short(word)
      "#{word.morphword} #{word.input}->#{word.output}"
    end
    private :word_string_short
  end
end

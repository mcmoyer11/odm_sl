# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/otlearn'
require 'otlearn/grammar_test_image_maker'
require 'otlearn/fsf_image_maker'
require 'otlearn/mmr_image_maker'

module OTLearn
  # An image maker that constructs a 2-dimensional sheet representation
  # of an Induction learning step.
  class InductionLearningImageMaker
    # Returns a new image maker for Induction Learning.
    #--
    # +fsf_image_maker+, +mmr_image_maker+, +grammar_test_image_maker+
    #  and +sheet_class+ are dependency injections used for testing.
    #++
    # :call-seq:
    #   InductionLearningImageMaker.new -> image_maker
    def initialize(fsf_image_maker: FsfImageMaker.new,
                   mmr_image_maker: MmrImageMaker.new,
                   grammar_test_image_maker: GrammarTestImageMaker.new,
                   sheet_class: Sheet)
      @fsf_image_maker = fsf_image_maker
      @mmr_image_maker = mmr_image_maker
      @grammar_test_image_maker = grammar_test_image_maker
      @sheet_class = sheet_class
    end

    # Returns a sheet containing the image of the induction learning step.
    # Raises a RuntimeError if the step subtype is unrecognized.
    # :call-seq:
    #   get_image(in_step) -> sheet
    def get_image(in_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Induction Learning'
      # Add the image for subtype-specific information
      sheet.append(get_subtype_image(in_step))
      # Construct and add Grammar Test information
      test_image = @grammar_test_image_maker.get_image(in_step.test_result)
      sheet.add_empty_row
      sheet.append(test_image)
      sheet
    end

    # Returns a sheet with the step subtype-specific image.
    # Raises a RuntimeError if the step subtype is unrecognized.
    def get_subtype_image(in_step)
      case in_step.step_subtype
      when FEWEST_SET_FEATURES
        @fsf_image_maker.get_image(in_step.fsf_step)
      when MAX_MISMATCH_RANKING
        @mmr_image_maker.get_image(in_step.mmr_step)
      else
        msg1 = 'InductionLearningImageMaker'
        raise RuntimeError "#{msg1}: invalid step subtype #{in_step.subtype}"
      end
    end
    private :get_subtype_image
  end
end

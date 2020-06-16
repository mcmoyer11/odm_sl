# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/grammar_test_image'
require 'otlearn/fewest_set_features_image'
require 'otlearn/max_mismatch_ranking_image'

module OTLearn
  # A 2-dimensional sheet representation of a InductionLearning object,
  # which contains a synopsis of an induction learning step.
  class InductionLearningImageMaker
    # Constructs an induction learning image from an induction learning step.
    #--
    # +fsf_image_class+, +mmr_image_class+, +grammar_test_image_class+
    #  and +sheet_class+ are dependency injections used for testing.
    #++
    # :call-seq:
    #   InductionLearningImageMaker.new -> image_maker
    def initialize(fsf_image_class: FewestSetFeaturesImage,
                   mmr_image_class: MaxMismatchRankingImage,
                   grammar_test_image_class: GrammarTestImage,
                   sheet_class: Sheet)
      @fsf_image_class = fsf_image_class
      @mmr_image_class = mmr_image_class
      @grammar_test_image_class = grammar_test_image_class
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
      test_image = @grammar_test_image_class.new(in_step.test_result)
      sheet.add_empty_row
      sheet.append(test_image)
      sheet
    end

    # Returns a sheet with the step subtype-specific image.
    # Raises a RuntimeError if the step subtype is unrecognized.
    def get_subtype_image(in_step)
      case in_step.step_subtype
      when InductionLearning::FEWEST_SET_FEATURES
        @fsf_image_class.new(in_step.fsf_step)
      when InductionLearning::MAX_MISMATCH_RANKING
        @mmr_image_class.new(in_step.mmr_step)
      else
        msg1 = 'InductionLearningImageMaker'
        raise RuntimeError "#{msg1}: invalid step subtype #{in_step.subtype}"
      end
    end
    private :get_subtype_image
  end
end

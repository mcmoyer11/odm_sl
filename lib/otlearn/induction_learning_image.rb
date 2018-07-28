# Author: Bruce Tesar

require 'sheet'
require 'otlearn/grammar_test_image'
require 'otlearn/fewest_set_features_image'
require 'otlearn/max_mismatch_ranking_image'

module OTLearn
  
  # A 2-dimensional sheet representation of a InductionLearning object,
  # which contains a synopsis of an induction learning step.
  #
  # This class delegates many methods to a Sheet object.
  class InductionLearningImage

    # Constructs an induction learning image from an induction learning object.
    #
    # * +step+ - the induction learning object
    # * +fsf_image_class+ - the class of object used to represent
    #   Fewest Set Features results for a given point in learning.
    #   Used for testing (dependency injection).
    # * +mmr_image_class+ - the class of object used to represent
    #   Max Mismatch Ranking results for a given point in learning.
    #   Used for testing (dependency injection).
    # * +grammar_test_image_class+ - the class of object used to represent
    #   grammar test results for a given point in learning.
    #   Used for testing (dependency injection).
    #
    # :call-seq:
    #   InductionLearningImage.new(language_learning) -> img
    def initialize(step,
        fsf_image_class: OTLearn::FewestSetFeaturesImage,
        mmr_image_class: OTLearn::MaxMismatchRankingImage,
        grammar_test_image_class: OTLearn::GrammarTestImage)
      @step = step
      @fsf_image_class = fsf_image_class
      @mmr_image_class = mmr_image_class
      @grammar_test_image_class = grammar_test_image_class
      @sheet = Sheet.new
      construct_induction_learning_image
    end

    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args, &block)
      @sheet.send(name, *args, &block)
    end
    protected :method_missing
    
    # Constructs the image from the induction learning step.
    def construct_induction_learning_image
      @sheet[1,1] = "Induction Learning"
      # Get the image for subtype-specific information
      case @step.step_subtype
      when InductionLearning::FEWEST_SET_FEATURES
        substep_image = @fsf_image_class.new(@step.fsf_step)
      when InductionLearning::MAX_MISMATCH_RANKING
        substep_image = @mmr_image_class.new(@step.mmr_step)
      else
        raise RuntimeError "InductionLearningImage: invalid step subtype #{step.subtype}"
      end
      @sheet.append(substep_image)
      # Construct and add Grammar Test information
      test_image = @grammar_test_image_class.new(@step.test_result)
      @sheet.add_empty_row
      @sheet.append(test_image)
    end
    protected :construct_induction_learning_image
  
  end # class InductionLearningImage
end # module OTLearn

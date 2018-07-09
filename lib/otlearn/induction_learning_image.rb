# Author: Bruce Tesar

require 'sheet'
require 'otlearn/grammar_test_image'

module OTLearn
  
  # A 2-dimensional sheet representation of a InductionLearning object,
  # which contains a synopsis of an induction learning step.
  #
  # This class delegates many methods to a Sheet object.
  class InductionLearningImage

    # Constructs an induction learning image from an induction learning object.
    #
    # * +step+ - the induction learning object
    #
    # :call-seq:
    #   InductionLearningImage.new(language_learning) -> img
    def initialize(step,
        grammar_test_image_class: OTLearn::GrammarTestImage)
      @step = step
      @grammar_test_image_class = grammar_test_image_class
      @sheet = Sheet.new
      construct_induction_learning_image
    end

    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args)
      @sheet.send(name, *args)
    end
    protected :method_missing
    
    # Constructs the image from the induction learning step.
    def construct_induction_learning_image
      @sheet[1,1] = "Induction Learning"
      #
      substep_image = Sheet.new
      case @step.step_subtype
      when InductionLearning::FEWEST_SET_FEATURES
#        substep_image = OTLearn::FewestSetFeaturesImage.new(@step)        
        substep_image[1,1] = "Fewest Set Features"
      when InductionLearning::MAX_MISMATCH_RANKING
#        substep_image = OTLearn::MaxMismatchRankingImage.new(@step)        
        substep_image[1,1] = "Max Mismatch Learning"        
      else
        raise RuntimeError "InductionLearningImage: invalid step subtype #{step.subtype}"
      end
      #
      @sheet.append(substep_image)
      test_image = @grammar_test_image_class.new(@step.test_result)
      @sheet.add_empty_row
      @sheet.append(test_image)
    end
    protected :construct_induction_learning_image
  
  end # class InductionLearningImage
end # module OTLearn

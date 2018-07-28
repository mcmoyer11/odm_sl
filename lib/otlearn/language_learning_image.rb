# Author: Bruce Tesar

require_relative '../sheet'
require_relative 'phonotactic_learning_image'
require_relative 'single_form_learning_image'
require_relative 'contrast_pair_learning_image'
require_relative 'induction_learning_image'
require_relative 'grammar_test_image'
require_relative 'language_learning'

module OTLearn
  
  # A 2-dimensional sheet representation of a LanguageLearning object,
  # which contains a synopsis of a language learning simulation.
  #
  # This class delegates many methods to a Sheet object.
  class LanguageLearningImage
    
    # Constructs a language learning image from a language learning object.
    #
    # * +language_learning+ - the language learning object
    # * +grammar_test_image_class+ - the class of object used to represent
    #   a grammar test results for a given point in learning.
    #   Used for testing (dependency injection).
    #
    # :call-seq:
    #   LanguageLearningImage.new(language_learning) -> img
    #   LanguageLearningImage.new(language_learning, grammar_test_image_class: class) -> img
    def initialize(language_learning,
        phonotactic_image_class: OTLearn::PhonotacticLearningImage,
        single_form_image_class: OTLearn::SingleFormLearningImage,
        contrast_pair_image_class: OTLearn::ContrastPairLearningImage,
        induction_image_class: OTLearn::InductionLearningImage,
        grammar_test_image_class: OTLearn::GrammarTestImage)
      @language_learning = language_learning
      @phonotactic_image_class = phonotactic_image_class
      @single_form_image_class = single_form_image_class
      @contrast_pair_image_class = contrast_pair_image_class
      @induction_image_class = induction_image_class
      @grammar_test_image_class = grammar_test_image_class
      @sheet = Sheet.new
      construct_language_learning_image
    end

    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args, &block)
      @sheet.send(name, *args, &block)
    end
    protected :method_missing
  
    # Constructs the image from the language learning object.
    def construct_language_learning_image
      # Put the language label first
      @sheet[1,1] = @language_learning.grammar.label
      # Indicate if learning succeeded.
      @sheet[2,1] = "Learned: #{@language_learning.learning_successful?}"
      # Add each step result to the sheet
      @language_learning.step_list.each do |step|
        step_image = construct_step_image(step)
        @sheet.add_empty_row
        @sheet.append(step_image)
      end
    end
    protected :construct_language_learning_image
    
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
      return step_image
    end
    protected :construct_step_image
  end # class LanguageLearningImage
end # module OTLearn

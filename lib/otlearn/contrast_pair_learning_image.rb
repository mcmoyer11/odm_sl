# Author: Bruce Tesar

module OTLearn
  
  # A 2-dimensional sheet representation of a ContrastPairLearning object,
  # which contains a synopsis of a contrast pair learning step.
  #
  # This class delegates many methods to a Sheet object.
  class ContrastPairLearningImage
    
    # Constructs a contrast pair learning image from a contrast pair learning object.
    #
    # * +step+ - the contrast pair learning object
    # * +grammar_test_image_class+ - the class of object used to represent
    #   grammar test results for a given point in learning.
    #   Used for testing (dependency injection).
    #
    # :call-seq:
    #   ContrastPairLearningImage.new(phonotactic_learning) -> img
    def initialize(step,
        grammar_test_image_class: OTLearn::GrammarTestImage)
      @step = step
      @grammar_test_image_class = grammar_test_image_class
      @sheet = Sheet.new
      construct_contrast_pair_learning_image
    end
    
    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args)
      @sheet.send(name, *args)
    end
    protected :method_missing
    
    # Constructs the image from the contrast pair learning step.
    def construct_contrast_pair_learning_image
      @sheet[1,1] = "Contrast Pair Learning"
      # Add the contrast pair to the sheet, or indicate that none were found.
      cpair = @step.contrast_pair
      if cpair then
        @sheet[2,2] = "Contrast Pair:"
        @sheet[2,3] = word_string_short(cpair[0])
        @sheet[2,4] = word_string_short(cpair[1])
      else
        @sheet[2,2] = "None Found"
      end
      # If the grammar changes, construct and add Grammar Test info.
      if @step.changed?
        test_image = @grammar_test_image_class.new(@step.test_result)
        @sheet.append(test_image)
      end
      return nil
    end
    protected :construct_contrast_pair_learning_image
    
    # Returns a string representing +word+ that is short, only giving
    # the morphword, input and output.
    def word_string_short(word)
      return "#{word.morphword} #{word.input}->#{word.output}"
    end
    protected :word_string_short
    
  end # class ContrastPairLearningImage
end # module OTLearn

# Author: Bruce Tesar

module OTLearn
  
  # A 2-dimensional sheet representation of a SingleFormLearning object,
  # which contains a synopsis of a single form learning step.
  #
  # This class delegates many methods to a Sheet object.
  class SingleFormLearningImage
    
    # Constructs a single form learning image from a single form learning object.
    #
    # * +step+ - the single form learning object
    # * +grammar_test_image_class+ - the class of object used to represent
    #   grammar test results for a given point in learning.
    #   Used for testing (dependency injection).
    #
    # :call-seq:
    #   SingleFormLearningImage.new(single_form_learning) -> img
    def initialize(step,
        grammar_test_image_class: OTLearn::GrammarTestImage)
      @step = step
      @grammar_test_image_class = grammar_test_image_class
      @sheet = Sheet.new
      construct_single_form_learning_image
    end
    
    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args, &block)
      @sheet.send(name, *args, &block)
    end
    protected :method_missing
    
    # Constructs the image from the single form learning step.
    def construct_single_form_learning_image
      @sheet[1,1] = "Single Form Learning"
      # Construct and add Grammar Test information
      test_image = @grammar_test_image_class.new(@step.test_result)
      @sheet.append(test_image)
    end
    protected :construct_single_form_learning_image
    
  end # class SingleFormLearningImage
end # module OTLearn

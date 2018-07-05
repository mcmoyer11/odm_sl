# Author: Bruce Tesar

require_relative '../sheet'
require_relative 'grammar_test_image'

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
        grammar_test_image_class: OTLearn::GrammarTestImage)
      @language_learning = language_learning
      @grammar_test_image_class = grammar_test_image_class
      @sheet = Sheet.new
      construct_language_learning_image
    end

    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args)
      @sheet.send(name, *args)
    end
    protected :method_missing
  
    # Constructs the image from the language learning object.
    def construct_language_learning_image
      # Put the language label first
      @sheet[1,1] = @language_learning.grammar.label
      # Indicate if learning succeeded.
      @sheet[2,1] = "Learned: #{@language_learning.learning_successful?}"
      # Add each step result to the sheet
      @language_learning.results_list.each do |result|
        grammar_test_image = @grammar_test_image_class.new(result)
        @sheet.add_empty_row
        @sheet.put_range[@sheet.row_count+1,1] = grammar_test_image
      end
    end
  end # class LanguageLearningImage
end # module OTLearn

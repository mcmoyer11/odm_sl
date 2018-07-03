# Author: Bruce Tesar

require_relative '../sheet'
require_relative 'rcd_bias_low'
require_relative '../rcd_image'
require_relative '../lexicon_image'

module OTLearn
  
  # A 2-dimensional sheet representation of a GrammarTest object.
  # The displayed results consist of:
  # * the label of the grammar test (e.g., the step of learning it follows)
  # * the ERCs of the grammar
  # * the lexicon of the grammar
  #
  # This class delegates many methods to a Sheet object.
  class GrammarTestImage
    
    # Constructs a grammar test image from a grammar_test object.
    # 
    # * +grammar_test+ - the result of a grammar test
    # * +rcd_class+ - the class implementing the version of RCD
    #   used to order the constraints for display purposes.
    # * +rcd_image_class+ - the class of object that will represent
    #   the results of RCD (erc tableau) image. Used for testing (dependency
    #   injection).
    # * +lexicon_image_class+ - the class of object that will represent
    #   the lexicon image. Used for testing (dependency injection).
    #
    # :call-seq:
    #   GrammarTestImage.new(grammar_test) -> img
    def initialize(grammar_test,
      rcd_class: OTLearn::RcdFaithLow, rcd_image_class: RcdImage,
      lexicon_image_class: LexiconImage)
      @grammar_test = grammar_test
      @rcd_class = rcd_class
      @rcd_image_class = rcd_image_class
      @lexicon_image_class = lexicon_image_class
      @sheet = Sheet.new
      construct_image
    end
    
    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args)
      @sheet.send(name, *args)
    end
    protected :method_missing
  
    # Constructs the image from the grammar test.
    def construct_image
      # insert the GrammarTest label
      @sheet[1,1] = @grammar_test.label
      # Compute the faith-low bias ranking, to provide the display
      # order of the constraints.
      rcd_result = @rcd_class.new(@grammar_test.grammar.erc_list)
      # Build the image of the support, and write it
      # to the page starting in column 2.
      rcd_image = @rcd_image_class.new(rcd_result)
      @sheet.put_range[@sheet.row_count+1,2] = rcd_image
      # Build the image of the lexicon, and write it
      # to the page starting in column 2, 2 rows after the support.
      lex_image = @lexicon_image_class.new(@grammar_test.grammar.lexicon)
      @sheet.put_range[@sheet.row_count+2,2] = lex_image
    end
    protected :construct_image
    
  end # class GrammarTestImage
end # module OTLearn

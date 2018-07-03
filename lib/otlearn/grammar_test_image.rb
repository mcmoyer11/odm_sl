# Author: Bruce Tesar

require_relative '../sheet'
require_relative 'rcd_bias_low'
require_relative '../rcd_image'
require_relative '../lexicon_image'

module OTLearn
  
  # Takes a grammar test object, and formats the results as a 2-dimensional
  # sheet. The displayed results consist of:
  # * the label of the grammar test (e.g., the step of learning it follows)
  # * the ERCs of the grammar
  # * the lexicon of the grammar
  class GrammarTestImage
    
    # Creates a grammar test image for the +grammar_test+.
    # The other parameters are dependency injections, for testing.
    def initialize(grammar_test,
      rcd_class: OTLearn::RcdFaithLow, rcd_image_class: RcdImage,
      lexicon_image_class: LexiconImage)
      @grammar_test = grammar_test
      @rcd_class = rcd_class
      @rcd_image_class = rcd_image_class
      @lexicon_image_class = lexicon_image_class
      @image = Sheet.new
      make_image
    end
    
    # Returns the sheet object constituting the image.
    def sheet
      @image
    end
    
    # Constructs the image from the grammar test.
    def make_image
      # insert the GrammarTest label
      @image[1,1] = @grammar_test.label
      # Compute the faith-low bias ranking, to provide the display
      # order of the constraints.
      rcd_result = @rcd_class.new(@grammar_test.grammar.erc_list)
      # Build the image of the support, and write it
      # to the page starting in column 2.
      rcd_image = @rcd_image_class.new(rcd_result)
      @image.put_range[@image.row_count+1,2] = rcd_image
      # Build the image of the lexicon, and write it
      # to the page starting in column 2, 2 rows after the support.
      lex_image = @lexicon_image_class.new(@grammar_test.grammar.lexicon)
      @image.put_range[@image.row_count+2,2] = lex_image
    end
    protected :make_image
    
  end # class GrammarTestImage
end # module OTLearn

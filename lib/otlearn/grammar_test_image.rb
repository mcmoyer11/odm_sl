# Author: Bruce Tesar

require_relative '../sheet'
require_relative 'rcd_bias_low'
require_relative '../rcd_image'
require_relative '../lexicon_image'

module OTLearn
  class GrammarTestImage
    def initialize(grammar_test, rcd_class: OTLearn::RcdFaithLow,
      rcd_image_class: RCD_image, lexicon_image_class: Lexicon_image)
      @grammar_test = grammar_test
      @rcd_class = rcd_class
      @rcd_image_class = rcd_image_class
      @lexicon_image_class = lexicon_image_class
      @image = Sheet.new
      make_image
    end
    
    def sheet
      @image
    end
    
    def make_image
      # insert the GrammarTest label
      @image[1,1] = @grammar_test.label
      # Compute the faith-low bias ranking.
      # TODO: GrammarTest should compute and provide the rcd_result.
      rcd_result = @rcd_class.new(@grammar_test.grammar.erc_list)
      # Build the image of the support, and write it
      # to the page starting in column 2.
      result_image = @rcd_image_class.new({:rcd=>rcd_result})
      @image.put_range[@image.row_count+1,2] = result_image.sheet
      # Build the image of the lexicon, and write it
      # to the page starting in column 2, 2 rows after the support.
      lex_image = @lexicon_image_class.new(@grammar_test.grammar.lexicon)
      @image.put_range[@image.row_count+2,2] = lex_image.sheet
      # Convert cells to blanks.
      @image.nil_to_blank!
    end
    protected :make_image
    
  end # class GrammarTestImage
end # module OTLearn

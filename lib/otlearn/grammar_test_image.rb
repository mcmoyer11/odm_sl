# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/faith_low'
require 'otlearn/ranking_bias_some_low'
require 'rcd_runner'
require 'rcd_image'
require 'lexicon_image'

module OTLearn
  # A 2-dimensional sheet representation of a GrammarTest object.
  # The displayed results consist of:
  # * the ERCs of the grammar
  # * the lexicon of the grammar
  #
  # This class delegates many methods to a Sheet object.
  class GrammarTestImage
    # Constructs a grammar test image from a +grammar_test+ result.
    #--
    # * +rcd_runner+ - the object providing the version of RCD
    #   used to order the constraints for display purposes.
    # * +rcd_image_class+ - the class of object that will represent
    #   the results of RCD (erc tableau) image. Used for testing (dependency
    #   injection).
    # * +lexicon_image_class+ - the class of object that will represent
    #   the lexicon image. Used for testing (dependency injection).
    #++
    # :call-seq:
    #   GrammarTestImage.new(grammar_test) -> img
    def initialize(grammar_test, rcd_runner: nil, rcd_image_class: RcdImage,
                   lexicon_image_class: LexiconImage)
      @grammar_test = grammar_test
      @rcd_runner = rcd_runner
      # The default rcd_runner uses RCD biased to low faithfulness
      if @rcd_runner.nil?
        @chooser = RankingBiasSomeLow.new(FaithLow.new)
        @rcd_runner = RcdRunner.new(@chooser)
      end
      @rcd_image_class = rcd_image_class
      @lexicon_image_class = lexicon_image_class
      @sheet = Sheet.new
      construct_image
    end

    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args, &block)
      @sheet.send(name, *args, &block)
    end
    protected :method_missing

    # Constructs the image from the grammar test.
    def construct_image
      # Compute the faith-low bias ranking, to provide the display
      # order of the constraints.
      rcd_result = @rcd_runner.run_rcd(@grammar_test.grammar.erc_list)
      # Build the image of the support, and write it
      # to the page starting in column 2.
      rcd_image = @rcd_image_class.new(rcd_result)
      @sheet.put_range[1, 2] = rcd_image
      # Build the image of the lexicon, and write it
      # to the page starting in column 2, 2 rows after the support.
      lex_image = @lexicon_image_class.new(@grammar_test.grammar.lexicon)
      @sheet.add_empty_row
      @sheet.append(lex_image, start_col: 2)
    end
    protected :construct_image
  end
end

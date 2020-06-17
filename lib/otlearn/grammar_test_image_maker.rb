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
  class GrammarTestImageMaker
    # Constructs a grammar test image from a +grammar_test+ result.
    #--
    # +rcd_runner+, +rcd_image_class+, +lexicon_image_class+
    # and +sheet_class+ are dependency injections used for testing.
    #++
    # :call-seq:
    #   GrammarTestImageMaker.new(grammar_test) -> image_maker
    def initialize(rcd_runner: nil, rcd_image_class: RcdImage,
                   lexicon_image_class: LexiconImage,
                   sheet_class: Sheet)
      @rcd_runner = rcd_runner
      # The default rcd_runner uses RCD biased to low faithfulness
      if @rcd_runner.nil?
        @chooser = RankingBiasSomeLow.new(FaithLow.new)
        @rcd_runner = RcdRunner.new(@chooser)
      end
      @rcd_image_class = rcd_image_class
      @lexicon_image_class = lexicon_image_class
      @sheet_class = sheet_class
    end

    # Returns a sheet containing the image of the grammar test.
    # :call-seq:
    #   get_image(grammar_test) -> sheet
    def get_image(grammar_test)
      sheet = @sheet_class.new
      # Compute the faith-low bias ranking, to provide the display
      # order of the constraints.
      rcd_result = @rcd_runner.run_rcd(grammar_test.grammar.erc_list)
      # Build the image of the support, and write it
      # to the page starting in column 2.
      rcd_image = @rcd_image_class.new(rcd_result)
      sheet.put_range[1, 2] = rcd_image
      # Build the image of the lexicon, and write it
      # to the page starting in column 2, 2 rows after the support.
      lex_image = @lexicon_image_class.new(grammar_test.grammar.lexicon)
      sheet.add_empty_row
      sheet.append(lex_image, start_col: 2)
      sheet
    end
  end
end

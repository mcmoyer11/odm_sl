# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/faith_low'
require 'otlearn/ranking_bias_some_low'
require 'rcd_runner'
require 'rcd_image_maker'
require 'lexicon_image_maker'

module OTLearn
  # Constructs a 2-dimensional sheet representation of a GrammarTest object.
  # The displayed results consist of:
  # * the ERCs of the grammar
  # * the lexicon of the grammar
  class GrammarTestImageMaker
    # Returns a new grammar test image maker.
    #--
    # +rcd_runner+, +rcd_image_maker+, +lexicon_image_maker+
    # and +sheet_class+ are dependency injections used for testing.
    #++
    # :call-seq:
    #   GrammarTestImageMaker.new -> image_maker
    def initialize(rcd_runner: nil, rcd_image_maker: RcdImageMaker.new,
                   lexicon_image_maker: LexiconImageMaker.new,
                   sheet_class: Sheet)
      @rcd_runner = rcd_runner
      # The default rcd_runner uses RCD biased to low faithfulness
      if @rcd_runner.nil?
        @chooser = RankingBiasSomeLow.new(FaithLow.new)
        @rcd_runner = RcdRunner.new(@chooser)
      end
      @rcd_image_maker = rcd_image_maker
      @lexicon_image_maker = lexicon_image_maker
      @sheet_class = sheet_class
    end

    # Returns a sheet containing the image of +grammar_test+.
    # :call-seq:
    #   get_image(grammar_test) -> sheet
    def get_image(grammar_test)
      sheet = @sheet_class.new
      # Compute the faith-low bias ranking, to provide the display
      # order of the constraints.
      rcd_result = @rcd_runner.run_rcd(grammar_test.grammar.erc_list)
      # Build the image of the support, and write it
      # to the page starting in column 2.
      rcd_image = @rcd_image_maker.get_image(rcd_result)
      sheet.put_range(1, 2, rcd_image)
      # Build the image of the lexicon, and write it
      # to the page starting in column 2, 2 rows after the support.
      lex_image = @lexicon_image_maker.get_image(grammar_test.grammar.lexicon)
      sheet.add_empty_row
      sheet.append(lex_image, start_col: 2)
      sheet
    end
  end
end

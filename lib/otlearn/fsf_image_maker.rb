# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'

module OTLearn
  # An image maker that constructs a 2-dimensional sheet representation
  # of a Fewest Set Features learning step.
  class FsfImageMaker
    # Returns a new image maker for Fewest Set Features.
    #--
    # +sheet_class+ is a dependency injection used for testing.
    #++
    # :call-seq:
    #   FsfImageMaker.new -> image_maker
    def initialize(sheet_class: Sheet)
      @sheet_class = sheet_class
    end

    # Returns a sheet containing the image of the FSF learning step.
    # :call-seq:
    #   get_image(fsf_step) -> sheet
    def get_image(fsf_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Fewest Set Features'
      # indicate if the grammar was changed
      sheet[2, 1] = "Grammar Changed: #{fsf_step.changed?.to_s.upcase}"
      add_failed_winner_info(fsf_step, sheet)
      sheet
    end

    # Adds info about the failed winner to the sheet
    def add_failed_winner_info(step, sheet)
      failed_winner = step.failed_winner
      subsheet = @sheet_class.new
      subsheet[1, 2] = 'Failed Winner'
      subsheet[1, 3] = failed_winner.morphword.to_s
      subsheet[1, 4] = failed_winner.input.to_s
      subsheet[1, 5] = failed_winner.output.to_s
      sheet.append(subsheet)
    end
    private :add_failed_winner_info
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'

module OTLearn
  # Creates a sheet image for an error step.
  class ErrorImageMaker
    # Returns a new error image maker.
    # :call-seq:
    #   ErrorImageMaker.new -> image_maker
    def initialize(sheet_class: Sheet)
      @sheet_class = sheet_class
    end

    # Returns a sheet containing an image of an error step.
    # :call-seq:
    #   get_image(err_step) -> sheet
    def get_image(err_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'ERROR: learning terminated'
      sheet[1, 2] = err_step.msg
      sheet
    end
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'csv'

# Constructs a CSV (comma-separated value) representation of a
# 2-dimensional +page_image+. An instance method, #write_to_file, can be
# used to write the CSV formatted output to a file. Uses the CSV library.
#
# :call-seq:
#   CsvOutput.new(page_image) -> csv_output
#--
# The named parameters sheet and csv_class are dependency injections used
# for testing.
class CsvOutput
  # Takes a page image, and automatically constructs a CSV image of it.
  def initialize(page_image, sheet: Sheet.new, csv_class: CSV)
    @page_image = page_image
    @csv_image = sheet
    @csv_class = csv_class
    construct_csv_image
  end

  # Write the CSV-formatted image to the file named _destination_.
  # It writes the column headers as the first line.
  def write_to_file(destination)
    @csv_class.open(destination, 'w', { write_headers: true }) do |csv|
      # Convert the csv image to an array, and send each row of the array
      # to CSV.
      @csv_image.to_a.each do |row|
        csv << row
      end
    end
  end

  # Writes the page image to the csv image, leaving the first row
  # as a header row filled with blanks.
  def construct_csv_image
    # Put the image in row 2, leaving row 1 as a header row.
    @csv_image.put_range[2, 1] = @page_image
    headers_nil_to_blank
  end
  private :construct_csv_image

  # Pad the first row so that any empty cells contain a blank (not nil).
  # The first row is treated as a header row by the NetBeans CSV editor,
  # and if an entry is nil, the CSV editor ignores the entire column,
  # truncating the display in the editor.
  def headers_nil_to_blank
    (1..@csv_image.col_count).each do |col|
      @csv_image[1, col] = ' ' unless @csv_image[1, col]
    end
  end
  private :headers_nil_to_blank
end

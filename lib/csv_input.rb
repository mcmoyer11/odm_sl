# frozen_string_literal: true

# Author: Bruce Tesar

require 'csv'

# A CsvInput object is given a filename when constructed. It opens the file,
# attempts to read the entire file as a CSV file, and produces an array
# of +headers+ (the first row of the CSV file), and an array +data+ of
# arrays (the other rows of the CSV file).
class CsvInput
  # An array of the column headers (as strings).
  attr_reader :headers

  # The data rows (rows 2 and later) as an array of arrays,
  # with each row array being an array of strings.
  attr_reader :data

  # Reads the contents of a CSV file. +infilename+ is a string that is
  # the filename of the file to be read. The contents of the file are
  # accessible from the returned CsvInput object.
  # :call-seq:
  #   CsvInput.new(infilename) -> csv_input
  def initialize(infilename)
    @filename = infilename
    @headers = []
    @data = []
    read_from_file
  end

  # Protected method, invoked by the constructor, that reads the contents
  # of the CSV file into an array of arrays, and then pulls off the first
  # row as a the array of column headers.
  def read_from_file
    @data = CSV.read(@filename)
    @headers = @data.shift
  end
  private :read_from_file
end

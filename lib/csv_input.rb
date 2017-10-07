# Author: Bruce Tesar

require 'csv'

# A CSV_Input object is given a filename when constructed. It opens the file,
# attempts to read the entire file as a CSV file, and produces an array
# of +headers+ (the first row of the CSV file), and an array +data+ of
# arrays (the other rows of the CSV file).
class CSV_Input

  # Reads the contents of a CSV file. +infilename+ is a string that is
  # the filename of the file to be read. The contents of the file are
  # accessible from the returned CSV_Input object.
  def initialize(infilename)
    @filename = infilename
    @headers = []
    @data = []
    read_from_file
  end

  # Returns an array of the column headers (as strings).
  def headers
    return @headers
  end

  # Returns the data rows (rows 2 and later) as an array of arrays,
  # which each row array being an array of strings.
  def data
    return @data
  end

  # Protected method, invoked by the constructor, that reads the contents
  # of the CSV file into an array of arrays, and then pulls off the first
  # row as a the array of column headers.
  def read_from_file
    @data = CSV.read(@filename)
    @headers = @data.shift
  end
  protected :read_from_file
end # class CSV_Input

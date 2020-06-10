# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar
#
# Scan through all the grammatical outputs of all the languages of the
# typology, and write to a text file all of the outputs that are not
# culminative.

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/resolver'

# Requires for classes needed in loading data from marshal file.
require 'output'
require 'pas/data'

# Read languages from a Marshal-format file, successively yielding
# the label and outputs of each language.
def read_languages_from_file(data_file)
  File.open(data_file, 'rb') do |fin|
    until fin.eof
      label, outputs = Marshal.load(fin)
      yield label, outputs
    end
  end
end

# Set up filenames and paths
data_path = File.join(File.dirname(__FILE__), '..', '..', 'data', 'pas')
data_filename = File.join(data_path, 'outputs_typology_1r1s.mar')
out_path = File.join(File.dirname(__FILE__), '..', '..', 'temp', 'pas')
Dir.mkdir(out_path) unless Dir.exist?(out_path)
out_filename = File.join(out_path, 'non_culminative_outputs.txt')

# List the non-culminative outputs
File.open(out_filename, 'w') do |outfile|
  read_languages_from_file(data_filename) do |label, outputs|
    outputs.each do |o|
      outfile.puts "#{label} #{o.morphword} #{o}" unless o.main_stress?
    end
  end
end

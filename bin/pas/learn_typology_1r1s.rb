# frozen_string_literal: true

# Author: Bruce Tesar / Morgan Moyer
#
# Tests learning on every language in the typology.
# All output is written to CSV files, one file for each language.

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/resolver'

require 'grammar'
require 'pas/system'
require 'pas/data'
require 'csv_output'
require 'otlearn/language_learning'
require 'otlearn/language_learning_image'

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

# ***********************************
# Actual execution of the simulation
# ***********************************

puts "\nLearning the PAS typology."

# Set the source of learning data (input file name)
data_path = File.join(File.dirname(__FILE__), '..', '..', 'data', 'pas')
data_file = File.join(data_path, 'outputs_typology_1r1s.mar')

# Set the target directory of learning results: temp/pas_learning.
# If the temp or pas_learning directories don't already exist, create them.
temp_filepath = File.join(File.dirname(__FILE__), '..', '..', 'temp')
Dir.mkdir temp_filepath unless Dir.exist? temp_filepath
out_filepath = File.join(temp_filepath, 'pas_learning')
Dir.mkdir out_filepath unless Dir.exist? out_filepath

# Learn the languages, writing output for each to a separate file.
read_languages_from_file(data_file) do |label, outputs|
  # Create a new, blank grammar, and assign it the label of the language.
  grammar = Grammar.new(system: PAS::System.instance)
  grammar.label = label
  # Run learning on the language
  lang_sim = OTLearn::LanguageLearning.new(outputs, grammar)
  sim_image = OTLearn::LanguageLearningImage.new(lang_sim)
  # Write the results to a CSV file, with the language label as the filename.
  out_file = File.join(out_filepath, "#{label}.csv")
  csv = CsvOutput.new(sim_image)
  csv.write_to_file(out_file)
  # Report to STDOUT if language was not successfully learned
  puts "#{label} not learned." unless lang_sim.learning_successful?
end
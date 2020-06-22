# frozen_string_literal: true

# Author: Bruce Tesar / Morgan Moyer
#
# Tests learning on every language in the typology.
# All output is written to CSV files, one file for each language.

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/odl/resolver'

require 'grammar'
require 'pas/system'
require 'pas/data'
require 'csv_output'
require 'otlearn/language_learning'
require 'otlearn/language_learning_image_maker'

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

# Set the source of learning data.
data_dir = File.expand_path('pas', ODL::DATA_DIR)
data_file = File.join(data_dir, 'outputs_typology_1r1s.mar')

# Set the target directory of learning results: temp/pas_learning.
# If the directory doesn't already exist, create it.
out_dir = File.expand_path('pas_learning', ODL::TEMP_DIR)
Dir.mkdir out_dir unless Dir.exist? out_dir

# Learn the languages, writing output for each to a separate file.
read_languages_from_file(data_file) do |label, outputs|
  # Create a new, blank grammar, and assign it the label of the language.
  grammar = Grammar.new(system: PAS::System.instance)
  grammar.label = label
  # Run learning on the language
  lang_sim = OTLearn::LanguageLearning.new
  result = lang_sim.learn(outputs, grammar)
  sim_image = OTLearn::LanguageLearningImageMaker.new.get_image(result)
  # Write the results to a CSV file, with the language label as the filename.
  out_file = File.join(out_dir, "#{label}.csv")
  csv = CsvOutput.new(sim_image)
  csv.write_to_file(out_file)
  # Report to STDOUT if language was not successfully learned
  puts "#{label} not learned." unless result.learning_successful?
end

# Author: Bruce Tesar
#
# Tests learning on language L20 of the SL system.
# The output is written to CSV file.

require_relative '../../lib/grammar'
require_relative '../../lib/sl/system'
require_relative '../../lib/sl/data'
require_relative '../../lib/csv_output'
require_relative '../../lib/otlearn/language_learning'
require_relative '../../lib/otlearn/language_learning_image'

# Set the target language label.
target_label = "LgL20"

# Set the source of learning data (input file name)
data_path = File.join(File.dirname(__FILE__),'..','..','data','sl')
data_file = File.join(data_path,'outputs_typology_1r1s.mar')
# Read L20 (label and outputs) from the SL languages data file.
label = nil
outputs = nil
File.open(data_file, 'rb') do |fin|
  until fin.eof do
    label, outputs = Marshal.load(fin)
    break if label == target_label
  end
end

# If the correct language wasn't found, write an error message and exit.
unless (label == target_label) then
  puts "Language #{target_label} not found in file #{data_file}."
  puts "No learning performed; the program will now exit."
  exit
end

# Set the target directory of learning results to temp.
# If the temp directory doesn't already exist, create it.
out_filepath = File.join(File.dirname(__FILE__),'..','..','temp')
Dir.mkdir out_filepath unless Dir.exist? out_filepath

# Create a new, blank grammar, and assign it the label of the language.
grammar = Grammar.new(system: SL::System.instance)
grammar.label = label
# Run learning on the language
lang_sim = OTLearn::LanguageLearning.new(outputs, grammar)
sim_image = OTLearn::LanguageLearningImage.new(lang_sim)

# Write the results to a CSV file, with the language label as the filename.
out_file = File.join(out_filepath,"#{label}.csv")
csv = CSV_Output.new(sim_image)
csv.write_to_file(out_file)
# Report to STDOUT if language was not successfully learned
unless lang_sim.learning_successful?
  puts "#{label} not learned."
end
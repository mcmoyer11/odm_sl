# Author: Bruce Tesar/Morgan Moyer
#
# Generates output data for Language A (ranking 2 from term paper), and learns from the
# generated outputs, storing results of learning in a CSV file.
 
require_relative '../../lib/otlearn/data_manip'
require_relative '../../lib/otlearn/language_learning'
require_relative '../../lib/pas/data'
require_relative '../../lib/csv_output'

# Set up the language label and the output file_pathname.
lang_label = "LgA_PAS"
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file = File.join(out_file_path,"#{lang_label}.csv")

# Delete the output file, so it will be clear if a new one isn't generated.
File.delete(out_file) if File.exist?(out_file)

# Generate the output forms of the language.
comp_list = PAS.generate_competitions_1r1s
winners = OTLearn.generate_language_from_competitions(comp_list, PAS.hier_a)
outputs = winners.map{|win| win.output}

# Create a new, blank grammar, and assign it the label of the language.
grammar = PAS::Grammar.new

grammar.label = lang_label

# Run learning on the language outputs, starting with the blank hypothesis.
lang_sim = OTLearn::LanguageLearning.new(outputs, grammar)

# Write the learning results to the CSV file.
csv = CSV_Output.new(lang_sim)
csv.write_to_file(out_file)

# Report to STDOUT if language was not successfully learned
unless lang_sim.learning_successful?
  puts "#{grammar.label} not learned."
end  

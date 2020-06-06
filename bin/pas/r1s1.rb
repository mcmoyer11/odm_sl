# Author: Bruce Tesar/Morgan Moyer
#
# Generates output data for Language A (ranking 2 from term paper), and learns from the
# generated outputs, storing results of learning in a CSV file.

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/resolver'

require 'grammar'
require 'pas/system'
require 'pas/data'
require 'csv_output'
require 'eval'
require 'language_generator'
require 'compare_ctie'
require 'otlearn/data_manip'
require 'otlearn/language_learning'
require 'otlearn/language_learning_image'

# Set up the language label and the output file_pathname.
lang_label = "LgA_PAS"
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file = File.join(out_file_path,"#{lang_label}.csv")

# Delete the output file, so it will be clear if a new one isn't generated.
File.delete(out_file) if File.exist?(out_file)

# Generate the output forms of the language.
comp_list = PAS.generate_competitions_1r1s
eval = Eval.new(CompareCtie.new(nil))
winners = LanguageGenerator.new(eval).generate_language(comp_list, PAS.hier_a)
outputs = winners.map{|win| win.output}

# Create a new, blank grammar, and assign it the label of the language.
grammar = Grammar.new(system: PAS::System.instance)

grammar.label = lang_label

# Run learning on the language outputs, starting with the blank hypothesis.
lang_sim = OTLearn::LanguageLearning.new(outputs, grammar)
sim_image = OTLearn::LanguageLearningImage.new(lang_sim)

# Write the learning results to the CSV file.
csv = CSV_Output.new(sim_image)
csv.write_to_file(out_file)

# Report to STDOUT if language was not successfully learned
unless lang_sim.learning_successful?
  puts "#{grammar.label} not learned."
end  

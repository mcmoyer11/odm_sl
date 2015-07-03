# Author: Bruce Tesar
#
# Generates output data for Language A (aka L20), stores them in a Marshal
# file (outputs_1r1s_LgA.mar), and then learns from the generated outputs,
# displaying the steps and results of learning in a CSV file.
 
require_relative '../lib/otlearn'
require_relative '../lib/sl/data'
require_relative '../lib/csv_output'

lang_label = "LgA"
dataname = File.join(File.dirname(__FILE__),'..','data',"outputs_1r1s_#{lang_label}.mar")
out_file_path = File.join(File.dirname(__FILE__),'..','temp')
out_file = File.join(out_file_path,"#{lang_label}.csv")

# Delete the output file, so it will be clear if a new one isn't generated.
File.delete(out_file) if File.exist?(out_file)

# Generate the output forms, and Marshal them to disk, with a label.
comp_list, gram = SL.generate_competitions_1r1s
winners, hyp =
  OTLearn.generate_learning_data_from_competitions(comp_list, SL.hier_a, SL::Grammar)
outputs = winners.map{|win| win.output}
File.open(dataname, "w") { |f| Marshal.dump([lang_label,outputs], f)  }

# Read the label and output forms from the Marshal file.
label, outputs = nil, nil # to give the variables scope outside the file block
File.open(dataname) { |f| label, outputs = Marshal.load(f)  }

# Create a new, blank hypothesis, and assign it the label of the language.
hyp = Hypothesis.new(SL::Grammar.new)
hyp.label = label

# Learning
lang_sim = OTLearn::LanguageLearning.new(outputs, hyp)

# Write to CSV file.
csv = CSV_Output.new(lang_sim)
csv.write_to_file(out_file)

# Author: Bruce Tesar
#
# Generates the entire topology for the SL system with
# monosyllabic morphemes and root+suffix words.
# Tests learning on every language in the typology.
# All output is written to CSV files, one file for each language.

require_relative '../lib/sl/data'
require_relative '../lib/hypothesis'
require_relative '../lib/otlearn'
require_relative '../lib/csv_output'
require_relative '../lib/factorial_typology'

dataname = File.join(File.dirname(__FILE__),'..','data','outputs_1r1s_Typology.mar')

def generate_languages(dataname)
  competition_list, gram = SL.generate_competitions_1r1s
  competition_list.auto_number_candidates
  ft_result = FactorialTypology.new(competition_list)
  lang_list = ft_result.factorial_typology
  # Write to file using Marshal
  #
  File.open(dataname, 'wb') do |f|
    lang_list.each do |lang|
      outputs, hyp = OTLearn::convert_ct_to_learning_data(lang, SL::Grammar)
      Marshal.dump(["Lg#{lang.label}",outputs], f)
    end
  end
end

# Uncomment the line below to regenerate the language typology data.
generate_languages(dataname)

#
# Learning
#
File.open(dataname, 'rb') do |fin|
  until fin.eof do
    label, outputs = Marshal.load(fin)
    # Create a new, blank hypothesis, and assign it the label of the language.
    hyp = Hypothesis.new(SL::Grammar.new)
    hyp.label = label
    # Language learning
    lang_sim = OTLearn::LanguageLearning.new(outputs, hyp)
    # Write the results to a CSV file, with the language label as the filename.
    csv = CSV_Output.new(lang_sim)
    out_file_path = File.join(File.dirname(__FILE__),'..','temp')
    out_file = File.join(out_file_path,"#{lang_sim.hypothesis.label}.csv")
    csv.write_to_file(out_file)
    # Report to STDOUT if language was not successfully learned
    unless lang_sim.learning_successful?
      puts "#{hyp.label} not learned:\n"
      puts "#{lang_sim.results_list.last.to_s}\n"
    end
  end
end

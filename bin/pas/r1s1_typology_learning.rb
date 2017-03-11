# Author: Bruce Tesar/Morgan Moyer
#
# Generates the entire typology for the PAS system with
# monosyllabic morphemes and root+suffix words.
# Tests learning on every language in the typology.
# All output is written to CSV files, one file for each language.

require_relative '../../lib/pas/data'
require_relative '../../lib/hypothesis'
require_relative '../../lib/otlearn/data_manip'
require_relative '../../lib/otlearn/language_learning'
require_relative '../../lib/csv_output'
require_relative '../../lib/factorial_typology'
require_relative '../../lib/otlearn/rcd_bias_low'

# Generate a list of sets of language data, one for each language
# in the typology of the PAS system, with each root and each suffix
# consisting of a single syllable.
def generate_languages
  competition_list, gram = PAS.generate_competitions_1r1s
  competition_list.auto_number_candidates
  ft_result = FactorialTypology.new(competition_list)
  lang_list = ft_result.factorial_typology
  return lang_list
end

# Writes a list +lang_list+ of language data to file +data_file+.
# Uses Marshal to write objects to file.
def write_language_list_to_file(lang_list, data_file)
  File.open(data_file, 'wb') do |f|
    lang_list.each do |lang|
      outputs, hyp = OTLearn::convert_ct_to_learning_data(lang, PAS::Grammar)
      Marshal.dump(["Lg#{lang.label}",outputs], f)
    end
  end  
end

# Read languages from a Marshal-format file, successively yielding
# the label and outputs of each language.
def read_languages_from_file(data_file)
  File.open(data_file, 'rb') do |fin|
    until fin.eof do
      label, outputs = Marshal.load(fin)
      yield label, outputs
    end
  end  
end

# Formats the language simulation results +lang_sim+ as CSV, and writes
# the formatted results to +csv_filename+.
def write_learning_results_to_csv(lang_sim, csv_file)
  csv = CSV_Output.new(lang_sim)
  csv.write_to_file(csv_file)  
end

#***********************************
# Actual execution of the simulation
#***********************************

# Generate the language typology data.
lang_list = generate_languages

# Write the languages to a file
data_file = File.join(File.dirname(__FILE__),'..','..','data','outputs_1r1s_Typology.mar')
write_language_list_to_file(lang_list, data_file)

# Report the number of languages in the typology
lang_count = 0
read_languages_from_file(data_file) do |label, outputs|
  lang_count += 1
end
puts "The typology has #{lang_count} languages."

# Learn the languages, writing output for each to a separate file.
out_filepath = File.join(File.dirname(__FILE__),'..','..','temp')
read_languages_from_file(data_file) do |label, outputs|
  # Create a new, blank hypothesis, and assign it the label of the language.
  hyp = Hypothesis.new(PAS::Grammar.new)
  hyp.label = label
  
  # Run learning on the language inside an Exception block to catch cases where
  # learning fails. A created class of Exceptions, LearnEx, returns a 
  # +language_learning+ object, which shows the stages of learning up to the point
  # where learning fails, and a +consistent_feature_val_list+, which shows which
  # feature-value-pairs are causing an error in the +language_learning+ file.
  lang_sim = nil
  begin
    lang_sim = OTLearn::LanguageLearning.new(outputs, hyp)
  rescue LearnEx => detail
    if lang_sim == nil
      STDERR.puts "More than one single matching feature passes error testing on #{label}."
      # Assign the Exception object to +lang_sim+ so a language_learning object
      # can be fed to +learning_sucessful?+
      lang_sim = detail.lang_learn
      # Output to the STDERR window the feature-value-pairs which are causing the 
      # learning to crash in the first place
      STDERR.puts detail.consistent_feature_value_list
    end
  end
  # Write the results to a CSV file, with the language label as the filename.
  out_file = File.join(out_filepath,"#{lang_sim.hypothesis.label}.csv")
  write_learning_results_to_csv(lang_sim, out_file)
  # Report to STDOUT if language was not successfully learned
  unless lang_sim.learning_successful?
    puts "#{hyp.label} not learned."
  end  
 end

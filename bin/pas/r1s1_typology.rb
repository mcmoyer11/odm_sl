# Author: Bruce Tesar/Morgan Moyer
#
# Generates the entire typology for the PAS system with
# monosyllabic morphemes and root+suffix words.
# Tests learning on every language in the typology.
# All output is written to CSV files, one file for each language.

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/resolver'

require 'pas/data'
require 'otlearn/data_manip'
require 'otlearn/language_learning'
require 'csv_output'
require 'factorial_typology'
require 'otlearn/rcd_bias_low'

# Generate a list of sets of language data, one for each language
# in the typology of the PAS system, with each root and each suffix
# consisting of a single syllable.
def generate_languages
  competition_list = PAS.generate_competitions_1r1s
  ft_result = FactorialTypology.new(competition_list)
  lang_list = ft_result.factorial_typology
  return lang_list
end

# Writes a list +lang_list+ of language data to file +data_file+.
# Uses Marshal to write objects to file.
def write_language_list_to_file(lang_list, data_file)
  File.open(data_file, 'wb') do |f|
    lang_list.each do |lang|
      outputs = OTLearn::convert_wl_pairs_to_learning_data(lang)
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
# Actual creation of the typology
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


#***************************************************
# Turning the typology into something easy to read.
#***************************************************

# Instead of making a +to_s+ on the factorial typology, I wrote the outputs
# and the hierarchy for each language into a file (this works very well)
out_file_path = File.join(File.dirname(__FILE__),'..','..','data') #'..' is parent directory
out_file = File.join(out_file_path,"pas_typology.csv")
File.open("pas_typology.csv","w+") do |file|
    lang_list.each do |lang|
      file.write(lang.label.to_s + "\t")
      file.write(OTLearn::RcdFaithLow.new(lang).hierarchy.to_s + "\n")
      winner_set = Set.new
      lang.each do |pair|
        winner_set.add(pair.winner)
      end
      winner_set.each do |w|
        file.write(w.to_s + "\n")
      end
    end
end

# Create a file with the hierarchy for each language.
out_file_path = File.join(File.dirname(__FILE__),'..','..','data') #'..' is parent directory
out_file = File.join(out_file_path,"pas_hierarchies.csv")
File.open("pas_hierarchies.csv", "w+") do |file|
  lang_list.each do |lang|
    file.write(lang.label.to_s + "\t")
    file.write(OTLearn::RcdFaithLow.new(lang).hierarchy.to_s + "\n")
  end
end


# Look at the languages with winners that are non-culminative.
out_file_path = File.join(File.dirname(__FILE__),'..','..','data') #'..' is parent directory
out_file = File.join(out_file_path,"pas_non-culm_winners.csv")
non_culm_winners = File.open("pas_non-culm_winners.csv","w+") do |file| 
  read_languages_from_file(data_file) do |label, outputs|
    outputs.each do |o|
      unless o.main_stress?
        file.write(label.to_s + "\n" + o.morphword.to_s + o.to_s + "\n")
      end 
    end
  end
end


# Pull the four languages that are failing learning: 32, 45, 46, 59
fails = lang_list.keep_if { |lang|
  lang.label.to_s == "L26" ||
  lang.label.to_s == "L33" }
#  lang.label.to_s == "L46" ||
#  lang.label.to_s == "L59" }

# Write those four to a file
File.open("pas_learning_fails.csv","w+") do |file|
    fails.each do |lang|
      file.write(lang.label.to_s + "\t")
      file.write(OTLearn::RcdFaithLow.new(lang).hierarchy.to_s + "\n")
      winner_set = Set.new
      lang.each do |pair|
        winner_set.add(pair.winner)
      end
      winner_set.each do |w|
        file.write(w.to_s + "\n")
      end
    end
end



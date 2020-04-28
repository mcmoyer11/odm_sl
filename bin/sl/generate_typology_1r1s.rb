# Author: Bruce Tesar
#
# Generates the entire topology for the SL system with
# monosyllabic morphemes and root+suffix words (1r1s).

require_relative '../../lib/sl/data'
require_relative '../../lib/factorial_typology'
require_relative '../../lib/otlearn/data_manip'

# Generate the language typology data:
# a list of sets of language data, one for each language in
# the typology of the SL system, with each root and each suffix
# consisting of a single syllable (1r1s).
competition_list = SL.generate_competitions_1r1s
ft_result = FactorialTypology.new(competition_list)
lang_list = ft_result.factorial_typology

# Write the data for each language of the typology to a data file.
# Uses Marshal to write objects to file.
data_path = File.join(File.dirname(__FILE__),'..','..','data','sl')
Dir.mkdir(data_path) unless Dir.exists?(data_path)
data_file = File.join(data_path,'outputs_typology_1r1s.mar')
File.open(data_file, 'wb') do |f|
  lang_list.each do |lang|
    outputs = OTLearn::convert_wl_pairs_to_learning_data(lang)
    Marshal.dump(["Lg#{lang.label}",outputs], f)
  end
end  

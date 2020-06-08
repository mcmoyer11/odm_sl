# frozen_string_literal: true

# Author: Bruce Tesar / Morgan Moyer
#
# Generates the entire topology for the PAS system with
# monosyllabic morphemes and root+suffix words (1r1s).

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/resolver'

require 'pas/data'
require 'factorial_typology'
require 'otlearn/data_manip'

# Generate the language typology data:
# a list of sets of language data, one for each language in
# the typology of the PAS system, with each root and each suffix
# consisting of a single syllable (1r1s).
competition_list = PAS.generate_competitions_1r1s
ft_result = FactorialTypology.new(competition_list)
lang_list = ft_result.factorial_typology

# Check for existence of data directories, and create them if necessary.
data_path = File.join(File.dirname(__FILE__), '..', '..', 'data')
Dir.mkdir(data_path) unless Dir.exist?(data_path)
out_path = File.join(data_path, 'pas')
Dir.mkdir(out_path) unless Dir.exist?(out_path)

# Write the data for each language of the typology to a data file.
# Uses Marshal to write objects to file.
out_file = File.join(out_path, 'outputs_typology_1r1s.mar')
File.open(out_file, 'wb') do |f|
  lang_list.each do |lang|
    outputs = OTLearn.convert_wl_pairs_to_learning_data(lang)
    Marshal.dump(["Lg#{lang.label}", outputs], f)
  end
end

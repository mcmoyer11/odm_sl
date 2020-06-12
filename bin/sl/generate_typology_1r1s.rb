# frozen_string_literal: true

# Author: Bruce Tesar
#
# Generates the entire topology for the SL system with
# monosyllabic morphemes and root+suffix words (1r1s).

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/odl/resolver'

require 'sl/data'
require 'factorial_typology'
require 'otlearn/data_manip'

# Generate the language typology data:
# a list of sets of language data, one for each language in
# the typology of the SL system, with each root and each suffix
# consisting of a single syllable (1r1s).
competition_list = SL.generate_competitions_1r1s
ft_result = FactorialTypology.new(competition_list)
lang_list = ft_result.factorial_typology

# Set the SL data directory.
data_dir = File.expand_path('sl', ODL::DATA_DIR)
# If the directory doesn't already exist, create it.
Dir.mkdir(data_dir) unless Dir.exist?(data_dir)

# Write the data for each language of the typology to a data file.
# Uses Marshal to write objects to file.
data_file = File.join(data_dir, 'outputs_typology_1r1s.mar')
File.open(data_file, 'wb') do |f|
  lang_list.each do |lang|
    outputs = OTLearn.convert_wl_pairs_to_learning_data(lang)
    Marshal.dump(["Lg#{lang.label}", outputs], f)
  end
end

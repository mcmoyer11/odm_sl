# Author: Morgan Moyer
#
# Generates output data for Language A (ranking 2 from term paper), and learns from the
# generated outputs, storing results of learning in a CSV file.
 
require_relative '../../lib/otlearn/data_manip'
require_relative '../../lib/otlearn/language_learning'
require_relative '../../lib/pas/data'
require_relative '../../lib/csv_output'

# For each language, take a look at the competition for each input.


###################
# Language 32
###################

# Set up the language label and the output file_pathname.
lang_label = "Lg32"
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file = File.join(out_file_path,"#{lang_label}.csv")

# Delete the output file, so it will be clear if a new one isn't generated.
File.delete(out_file) if File.exist?(out_file)

# Set up the hierarchy for L32
hier = Hierarchy.new
hier << [PAS::SYSTEM.mr] << [PAS::SYSTEM.idlength] << [PAS::SYSTEM.nolong, PAS::SYSTEM.wsp] <<
  [PAS::SYSTEM.idstress] << [PAS::SYSTEM.ml, PAS::SYSTEM.culm]

# Generate the output forms of the language.
comp_list, gram = PAS.generate_competitions_1r1s
winners, hyp =
  OTLearn.generate_learning_data_from_competitions(comp_list, hier, PAS::Grammar)
outputs = winners.map{|win| win.output}

puts winners.each {|w| w.to_s + "\n"}

# Take a look at all the competitions for L32
File.open("pas_failures_L32.csv","w+") do |file|
  file.write(hier.to_s + "\n")
  comp_list.each do |c|
    file.write(c.to_s + "\n")
  end
end


###################
# Language 45
###################

# Set up the language label and the output file_pathname.
lang_label = "Lg45"
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file = File.join(out_file_path,"#{lang_label}.csv")

# Delete the output file, so it will be clear if a new one isn't generated.
File.delete(out_file) if File.exist?(out_file)

# Set up the hierarchy for L45
hier = Hierarchy.new
hier << [PAS::SYSTEM.wsp] << [PAS::SYSTEM.idstress] << [PAS::SYSTEM.culm] << [PAS::SYSTEM.idlength] <<
  [PAS::SYSTEM.nolong, PAS::SYSTEM.mr] << [PAS::SYSTEM.ml]

# Generate the output forms of the language.
comp_list, gram = PAS.generate_competitions_1r1s
winners, hyp =
  OTLearn.generate_learning_data_from_competitions(comp_list, hier, PAS::Grammar)
outputs = winners.map{|win| win.output}

puts winners.each {|w| w.to_s + "\n"}

# Take a look at all the competitions for L46
File.open("pas_failures_L45.csv","w+") do |file|
  file.write(hier.to_s + "\n")
  comp_list.each do |c|
    file.write(c.to_s + "\n")
  end
end

###################
# Language 46
###################

# Set up the language label and the output file_pathname.
lang_label = "Lg46"
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file = File.join(out_file_path,"#{lang_label}.csv")

# Delete the output file, so it will be clear if a new one isn't generated.
File.delete(out_file) if File.exist?(out_file)

# Set up the hierarchy for L46
hier = Hierarchy.new
hier << [PAS::SYSTEM.wsp] << [PAS::SYSTEM.idstress] << [PAS::SYSTEM.culm] << 
  [PAS::SYSTEM.idlength] << [PAS::SYSTEM.nolong, PAS::SYSTEM.ml] << [PAS::SYSTEM.mr]

# Generate the output forms of the language.
comp_list, gram = PAS.generate_competitions_1r1s
winners, hyp =
  OTLearn.generate_learning_data_from_competitions(comp_list, hier, PAS::Grammar)
outputs = winners.map{|win| win.output}

puts winners.each {|w| w.to_s + "\n"}

# Take a look at all the competitions for L46
File.open("pas_failures_L46.csv","w+") do |file|
  file.write(hier.to_s + "\n")
  comp_list.each do |c|
    file.write(c.to_s + "\n")
  end
end


###################
# Language 59
###################

# Set up the language label and the output file_pathname.
lang_label = "Lg59"
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file = File.join(out_file_path,"#{lang_label}.csv")

# Delete the output file, so it will be clear if a new one isn't generated.
File.delete(out_file) if File.exist?(out_file)

# Set up the hierarchy for L59
hier = Hierarchy.new
hier << [PAS::SYSTEM.ml] << [PAS::SYSTEM.idlength] << [PAS::SYSTEM.nolong, PAS::SYSTEM.wsp] <<
  [PAS::SYSTEM.idstress] << [PAS::SYSTEM.mr, PAS::SYSTEM.culm]

# Generate the output forms of the language.
comp_list, gram = PAS.generate_competitions_1r1s
winners, hyp =
  OTLearn.generate_learning_data_from_competitions(comp_list, hier, PAS::Grammar)
outputs = winners.map{|win| win.output}

puts winners.each {|w| w.to_s + "\n"}

# Take a look at all the competitions for L46
File.open("pas_failures_L59.csv","w+") do |file|
  file.write(hier.to_s + "\n")
  comp_list.each do |c|
    file.write(c.to_s + "\n")
  end
end


#PAS

require_relative '../../lib/otlearn/data_manip'
require_relative '../../lib/otlearn/language_learning'
require_relative '../../lib/pas/data'
require_relative '../../lib/csv_output'
require_relative '../../lib/competition_list.rb'
require_relative '../../lib/competition.rb'
require_relative '../../lib/word.rb'

###############
# this file contains practice for writing codes to files and playing around with
# accessing the information in a comparative_tableau.


lang_label = "Lang_A"
out_file_path = File.join(File.dirname(__FILE__),'..','temp') #'..' is parent directory
out_file = File.join(out_file_path,"#{lang_label}.csv")
#
## Generate the output forms of the language.
comp_list, gram = PAS.generate_competitions_1r1s
hier = PAS.hier_a
#

wins = comp_list.each {|c| c.winners}
# puts wins

#
lang_a = OTLearn::generate_language_from_competitions(comp_list, hier)
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file_a = File.join(out_file_path,"lang_a.txt")
# File.open(out_file, "w+") {|file| file.write(lang_a.to_s)}
#puts lang_a
##

winners, hyp = OTLearn::generate_learning_data_from_competitions(comp_list, hier, PAS::Grammar)
File.open("winners_a.txt", "w+") {|file| 
  winners.each{|w| file.write(w.to_s + "\n")}}

File.open("hyp_a.txt", "w+") {|file| 
  file.write(hyp.to_s + "\n")}


#


###################################################
## Experimenting with outputs, trying to create 
# figure out what the difference between super
# and dup.
################################

test_out = Output.new
test_out.morphword=("the word")
test_out << "first" << "second"
puts "#{test_out.morphword} #{test_out}"
d_test = test_out.dup
puts "#{d_test.morphword} #{d_test}"

def test_out.non_super_dup
    copy = Output.new.concat(map { |el| el.dup })
    copy.morphword = @morphword.dup unless @morphword.nil?
    return copy
end

ns_test = test_out.non_super_dup
puts "#{ns_test.morphword} #{ns_test}"

#################################################################
# 
# look at the outputs for all the languages in the typology

#################################################################


lang_a = OTLearn::generate_language_from_competitions(comp_list, hier)
out_file_path = File.join(File.dirname(__FILE__),'..','..','temp') #'..' is parent directory
out_file_a = File.join(out_file_path,"lang_a.txt")

lang = OTLearn::generate_language_from_competitions(comp_list, hier)

# Author: Morgan Moyer
#
#
# This class of exceptions holds the +languge_learning+ object
# for languages which fail MMR learning. It is used in the language_learning and 
# r1s1_typology_learning_mmr files. 
#

#TODO: this should be contained in the module OTLearn.

class MMREx < RuntimeError
  
  attr_reader :lang_learn
  attr_reader :failed_winner
  
  def initialize(failed_winner, lang_learn)
    @failed_winner = failed_winner
    @lang_learn = lang_learn
  end
  
end


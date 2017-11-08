# Author: Morgan Moyer
#
#
# This class of exceptions holds the +languge_learning+ object and the +feature_value_list+
# for languages which fail learning. It is used in the +language_learning+ and 
# +r1s1_typology_learning+ files.
#


class LearnEx < RuntimeError
  
  attr_reader :lang_learn
  attr_reader :consistent_feature_value_list
  attr_reader :failed_winner_orig
  attr_reader :main_hypothesis
  
  def initialize(lang_learn, failed_winner_orig, main_hypothesis, consistent_feature_value_list)
    @lang_learn = lang_learn
    @failed_winner_orig = failed_winner_orig
    @main_hypothesis = main_hypothesis
    @consistent_feature_value_list = consistent_feature_value_list
  end
  
end

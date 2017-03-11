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
  
  def initialize(lang_learn, consistent_feature_value_list)
    @lang_learn = lang_learn
    @consistent_feature_value_list = consistent_feature_value_list
  end
  
end

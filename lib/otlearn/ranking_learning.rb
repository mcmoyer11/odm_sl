# Author: Bruce Tesar
#

require_relative 'data_manip'
require 'loserselector_by_ranking'
require_relative 'mrcd'

module OTLearn
  
  # Performs ranking learning on the given word list, using the
  # given hypothesis. The parameter hypothesis is directly updated
  # during execution. Returns true if any change at all is made to
  # the hypothesis (any new winner-loser pairs are added).
  # 
  # The underlying form for each word is set so that each feature matches
  # the underlying value if it is set in the lexicon, and otherwise
  # matches the surface value of the feature in the word.

  def OTLearn::ranking_learning_faith_low(word_list, hypothesis)
    winner_list = data_dup_and_match_output(word_list)
    # Use the faith-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(hypothesis.system, OTLearn::RcdFaithLow)
    mrcd_result = Mrcd.new(winner_list, hypothesis, selector)
    return mrcd_result.any_change?
  end
  
  def OTLearn::ranking_learning_mark_low(word_list, hypothesis)
    winner_list = data_dup_and_match_output(word_list)
    # Use the mark-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(hypothesis.system, OTLearn::RcdMarkLow)
    mrcd_result = Mrcd.new(winner_list, hypothesis, selector)
    return mrcd_result.any_change?    
  end
  
  def OTLearn::data_dup_and_match_output(word_list)
    # Duplicate the words
    winner_list = word_list.map{|word| word.dup}
    # Set unset input features to match their output correspondent values.
    winner_list.each {|winner| OTLearn::match_input_to_uf!(winner)}
    winner_list.each {|winner| OTLearn::match_input_to_output!(winner)}
    return winner_list
  end
  
end # module OTLearn

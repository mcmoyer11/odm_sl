# Author: Bruce Tesar
#

require_relative 'data_manip'
require 'loserselector_by_ranking'
require 'loser_selector_exhaustive'
require_relative 'mrcd'

module OTLearn
  
  def OTLearn.ranking_learning(word_list, grammar, selector, mrcd_class: Mrcd)
    mrcd_result = mrcd_class.new(word_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result
  end
  
  # Performs ranking learning on the given word list, using the
  # given grammar. The parameter +grammar+ is directly updated
  # with the additional winner-loser pairs obtained. Loser selection is
  # done using the Faith Low ranking bias.
  # 
  # Returns true if any change at all is made to
  # the grammar (any new winner-loser pairs are added).
  # 
  # The underlying form for each word is set so that each feature matches
  # the underlying value if it is set in the lexicon, and otherwise
  # matches the surface value of the feature in the word.
  def OTLearn::ranking_learning_faith_low(word_list, grammar)
    winner_list = data_dup_and_match_output(word_list)
    # Use the faith-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(grammar.system, rcd_class: OTLearn::RcdFaithLow)
    mrcd_result = Mrcd.new(winner_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result.any_change?
  end
  
  #returns an mrcd_result object rather than a boolean
  def OTLearn::ranking_learning_faith_low_mrcd(word_list, grammar)
    winner_list = data_dup_and_match_output(word_list)
    # Use the faith-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(grammar.system, rcd_class: OTLearn::RcdFaithLow)
    mrcd_result = Mrcd.new(winner_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result
  end
  
  def OTLearn::ranking_learning_faith_low_no_mod(word_list, grammar)
    winner_list = word_list
    # Use the faith-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(grammar.system, rcd_class: OTLearn::RcdFaithLow)
    mrcd_result = Mrcd.new(winner_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result
  end

  # Performs ranking learning on the given word list, using the
  # given grammar. The parameter +grammar+ is directly updated
  # with the additional winner-loser pairs obtained. Loser selection is
  # done using the Mark Low ranking bias.
  # 
  # Returns true if any change at all is made to
  # the grammar (any new winner-loser pairs are added).
  # 
  # The underlying form for each word is set so that each feature matches
  # the underlying value if it is set in the lexicon, and otherwise
  # matches the surface value of the feature in the word.  
  def OTLearn::ranking_learning_mark_low(word_list, grammar)
    winner_list = data_dup_and_match_output(word_list)
    # Use the mark-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(grammar.system, rcd_class: OTLearn::RcdMarkLow)
    mrcd_result = Mrcd.new(winner_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result.any_change?    
  end
  
  #returns an mrcd_result object rather than a boolean
  def OTLearn::ranking_learning_mark_low_mrcd(word_list, grammar)
    winner_list = data_dup_and_match_output(word_list)
    # Use the mark-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(grammar.system, rcd_class: OTLearn::RcdMarkLow)
    mrcd_result = Mrcd.new(winner_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result    
  end
  
  #returns an mrcd_result object rather than a boolean
  # does not modify the winner list to match outputs
  def OTLearn::ranking_learning_mark_low_no_mod(word_list, grammar)
    winner_list = word_list
    # Use the mark-low ranking bias for ranking learning
    selector = LoserSelector_by_ranking.new(grammar.system, rcd_class: OTLearn::RcdMarkLow)
    mrcd_result = Mrcd.new(winner_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result    
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

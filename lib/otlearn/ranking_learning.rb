# Author: Bruce Tesar
#

require_relative 'mrcd'

module OTLearn
  
  # Performs ranking learning on the +word list+, using the
  # +grammar+. Loser selection is done via the +selector+.
  # The +grammar+ is directly updated with the additional winner-loser
  # pairs obtained. The class of object used to implement multi-recursive
  # constraint demotion is optionally passed via the named parameter
  # +mrcd_class+ (defaults to class Mrcd).
  # 
  # Returns the mrcd_class object representing the results of ranking learning.
  def OTLearn.ranking_learning(word_list, grammar, selector, mrcd_class: Mrcd)
    mrcd_result = mrcd_class.new(word_list, grammar, selector)
    mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
    return mrcd_result
  end
  
end # module OTLearn

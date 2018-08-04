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

  # Looks for new ranking information from nonfaithful mappings of the given
  # feature within the given word list, relative to the given grammar.
  # Any new ranking information is added to the grammar.
  # Returns true if any new ranking information was obtained; false otherwise.
  def OTLearn.new_rank_info_from_feature(grammar, word_list, uf_feat_inst,
      learning_module: OTLearn, loser_selector: nil)
    # Assign the default value for loser_selector
    if loser_selector.nil? then
      loser_selector = LoserSelectorExhaustive.new(grammar.system)
    end
    # find words containing the same morpheme as the set feature
    containing_words = word_list.find_all do |w|
      w.morphword.include?(uf_feat_inst.morpheme)
    end
    # find words with output value of set feature that differs from the uf set value.
    uo_conflict_words = containing_words.inject([]) do |cwords, word|
      out_feat_inst = word.out_feat_corr_of_uf(uf_feat_inst)
      unless out_feat_inst.nil?
        cwords << word if uf_feat_inst.value != out_feat_inst.value
      end
      cwords
    end
    # Duplicate and output-match the conflict words
    dup_conflict_words = uo_conflict_words.map do |word|
      dup = grammar.parse_output(word.output)
      dup.match_input_to_output!
      dup
    end
    # Run each such word through MRCD, searching for new ranking info
    return learning_module.
      ranking_learning(dup_conflict_words, grammar, loser_selector)
  end
  
end # module OTLearn

# Author: Bruce Tesar
#
# This file contains a collection of methods for generating and
# manipulating data.

require 'set'
require 'loserselector_by_ranking'

module OTLearn
  
  # Given a list of words and a grammar, check the word list for
  # consistency with the grammar using MRCD. Any features unset
  # in the lexicon of the grammar are set in the input of a word
  # to the value opposite its output correspondent in the word.
  # The mismatching is done separately for each word (the same unset feature
  # for a morpheme might be assigned different values in the inputs of
  # different words containing that morpheme, depending on what the outputs
  # of those words are).
  # Returns the Mrcd object containing the results.
  # To find out if the word list is consistent with the grammar, call
  # result.grammar.consistent? (where result is the Mrcd object returned
  # by #mismatch_consistency_check).
  def OTLearn.mismatch_consistency_check(grammar, word_list)
    # Parse the outputs of the word_list to create test copies matching
    # the lexicon, and mismatch the unset features to the output.
    mismatch_list = word_list.map do |winner| 
      word = grammar.system.parse_output(winner.output, grammar.lexicon)
      word.mismatch_input_to_output!
    end
    # Run MRCD to see if the mismatched candidates are consistent.
    selector = LoserSelector_by_ranking.new(grammar.system)
    mrcd = Mrcd.new(mismatch_list, grammar, selector)
    return mrcd
  end

  # Takes a competition list and a hierarchy, and returns a list of
  # structural descriptions that are optimal with respect to the hierarchy.
  # The returned structural description objects are the same objects as
  # the matching ones in the competition list. Each optimal description has
  # its optimal flag set to true.
  def OTLearn::generate_language_from_competitions(comp_list, hier)
    comp_mh = comp_list.map{|comp| MostHarmonic.new(comp,hier)}
    # each competition returns a list of winners; collapse to one-level list.
    lang = comp_mh.inject([]){|winners, mh_list| winners.concat(mh_list) }
    lang.each{|winner| winner.assert_opt}
    return lang
  end

  # Given a list of winner_loser pairs +wlp_list+, returns a set of
  # the winners in the pairs of the list (with no duplicates).
  def OTLearn::wlp_winners(wlp_list)
    winners = Set.new # Set automatically filters duplicate entries
    wlp_list.each do |wlp|
      winners.add(wlp.winner)
    end
    return winners
  end
  
  # Takes a language in the form of a list of WL pairs (with
  # each represented form of the language appearing as a winner in at least
  # one pair), and returns a list of the winner outputs.
  def OTLearn::convert_wl_pairs_to_learning_data(wl_pairs)
    # Extract the outputs of the grammatical candidates of the language.
    outputs = wlp_winners(wl_pairs).map{|winner| winner.output}
    return outputs
  end
  
end # module OTLearn

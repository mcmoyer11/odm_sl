# frozen_string_literal: true

# Author: Bruce Tesar
#
# This file contains a collection of methods for generating and
# manipulating data.

require 'set'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

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
      word = grammar.parse_output(winner.output)
      word.mismatch_input_to_output!
    end
    # Run MRCD to see if the mismatched candidates are consistent.
    basic_selector = LoserSelector.new(CompareConsistency.new)
    loser_selector = LoserSelectorFromGen.new(grammar.system, basic_selector)
    mrcd = Mrcd.new(mismatch_list, grammar, loser_selector)
    mrcd
  end

  # Given a list of winner_loser pairs +wlp_list+, returns a set of
  # the winners in the pairs of the list (with no duplicates).
  def OTLearn::wlp_winners(wlp_list)
    winners = Set.new # Set automatically filters duplicate entries
    wlp_list.each do |wlp|
      winners.add(wlp.winner)
    end
    winners
  end

  # Takes a language in the form of a list of WL pairs (with
  # each represented form of the language appearing as a winner in at least
  # one pair), and returns a list of the winner outputs.
  def OTLearn::convert_wl_pairs_to_learning_data(wl_pairs)
    # Extract the outputs of the grammatical candidates of the language.
    outputs = wlp_winners(wl_pairs).map{|winner| winner.output}
    outputs
  end
end

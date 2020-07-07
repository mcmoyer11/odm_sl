# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/data_manip'
require 'otlearn/uf_learning'
require 'otlearn/contrast_set'
require 'otlearn/grammar_test'
require 'word_search'

module OTLearn
  # Yields a sequence of contrast pairs. A contrast pair is a ContrastSet
  # containing two words which share a single morpheme.
  #
  # This method is defined to be called by an external iterator. The first
  # parameter, cp_return, is the return object for the calling iterator.
  #
  # Example:
  #   cp_gen = Enumerator.new do |result|
  #     OTLearn.generate_contrast_pair(result, winner_list, grammar,
  #                                    prior_result)
  #   end
  #   loop {contrast_pair = cp_gen.next; <...>}
  #--
  # Values (contrast pairs) are returned by calling cp_return.yield(<pair>).
  #++
  #
  # Given a list of winners for the language, a grammar, and
  # the GrammarTest result for the winners on that grammar, this method
  # identifies failed winners (ones whose optimality is not yet ensured).
  # For each failed winner (FW) in sequence, other winners are searched for
  # that:
  # * share a morpheme with the FW;
  # * have a conflicting value (with the FW) on a feature unset in the lexicon.
  # Such winners are used to form contrast pairs with the failed winner.
  # These have potential, because:
  # * the failed winner has at least one feature that needs setting;
  # * the alternating unset feature ensures some additional mutual restriction
  #   between the forms of the pair beyond processing each in isolation.
  def OTLearn.generate_contrast_pair(cp_return, winners, grammar,
                                     test_result = nil)
    grammar_tester = GrammarTest.new
    test_result ||= grammar_tester.run(winners, grammar)
    # The failed winners of the test are connected to a different
    # lexicon. Parse the outputs with +grammar+ to generate distinct
    # candidates in correspondence with the lexicon of +grammar+.
    f_winners = test_result.failed_winners.map do |winner|
      output = winner.output
      grammar.parse_output(output)
    end
    # For each failed winner, look for qualifying contrast pairs
    f_winners.each do |failed_winner|
      failed_winner.morphword.each do |morph|
        # Find features of morph that are unset in the lexicon.
        unset_features =
            WordSearch.new.find_unset_features([morph], grammar)
        next(nil) if unset_features.empty? # go to next morpheme

        # Find all words containing that morpheme, except the original
        # failed winner.
        morph_to_word_hash = WordSearch.new.morphemes_to_words(winners)
        containing_words = morph_to_word_hash[morph]
        containing_words = containing_words.delete_if do |cword|
          cword.morphword == failed_winner.morphword
        end
        containing_words.each do |word|
          # Find an unset feature of morph that alternates between
          # failed_winner and word.
          alternating_feature = unset_features.find do |feat_inst|
            OTLearn.conflicting_output_values?(feat_inst,
                                               [failed_winner, word])
          end
          # If an alternating feature was found, yield the contrast pair
          # to the calling iterator.
          unless alternating_feature.nil?
            cp = OTLearn::ContrastSet.new([failed_winner, word])
            cp_return.yield cp
          end
        end
      end
    end
    # TODO: improve the logic for words with greater than two morphemes,
    #       to avoid duplication of words sharing more than one morpheme
    #       with the failed winner.
  end
end

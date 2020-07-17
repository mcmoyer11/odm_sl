# frozen_string_literal: true

# Author: Bruce Tesar

require 'word_search'

module OTLearn
  # Learning of the values of underlying features via inconsistency
  # detection. Main execution of learning is performed when the instance
  # method #run is called. The list of words passed into #run is treated
  # as a related group: an underlying feature can be set if only one
  # value for the feature permits all of the words to simultaneously
  # be optimal.
  class FeatureValueLearning
    # Returns a new FeatureValueLearning object.
    #--
    # The named parameter _word_search_ is a dependency injection used
    # for testing.
    def initialize(word_search: WordSearch.new, learn_module: OTLearn)
      @word_search = word_search
      @learn_module = learn_module
    end

    # Attempt to set the underlying values of unset features in
    # the given _words_, using the given _grammar_. The word
    # objects in _words_ are not modified (working copies are made).
    # Returns an array of underlying features that were set during
    # execution; returns an empty array if no features were set.
    # :call-seq:
    #   run(words, grammar) -> array
    def run(words, grammar)
      word_list = create_match_words(words, grammar)
      conflict, no_conflict = partition_unset_features(word_list, grammar)
      # TODO: Test conflicting features
      set_conflict_features = []
      set_no_conflict_features =
        test_non_conflicting_features(word_list, grammar, conflict,
                                      no_conflict)
      set_conflict_features + set_no_conflict_features
    end

    # Create duplicates of the _words_ for working purposes, and
    # match the unset input feature values to their corresponding
    # outputs.
    def create_match_words(words, grammar)
      # Duplicate the words (working copies for this method)
      word_list = words.map do |word|
        grammar.parse_output(word.output)
      end
      # Set all unset input features to match their output correspondents
      word_list.each(&:match_input_to_output!)
      word_list
    end
    private :create_match_words

    # Returns two lists of unset underlying features: those that have
    # conflicting values in the outputs, and those that do not.
    def partition_unset_features(word_list, grammar)
      morph_in_words = @word_search.morphemes_to_words(word_list)
      morpheme_list = morph_in_words.keys
      unset_features =
        @word_search.find_unset_features(morpheme_list, grammar)
      unset_features.partition do |f|
        @word_search.conflicting_output_values?(f, morph_in_words[f.morpheme])
      end
    end
    private :partition_unset_features

    # Test each non-conflicting unset feature to see if it can be set
    def test_non_conflicting_features(word_list, grammar, conflict, no_conflict)
      set_feature_list = []
      no_conflict.each do |f_uf_instance|
        f_was_set =
          @learn_module.test_unset_feature(f_uf_instance, word_list,
                                           conflict, grammar)
        set_feature_list << f_uf_instance if f_was_set
      end
      set_feature_list
    end
    private :test_non_conflicting_features
  end
end

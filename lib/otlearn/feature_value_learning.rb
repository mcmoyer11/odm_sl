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
    #
    # NOTE: technically, this method only attempts to set the values
    # of features that do not alternate across _words_. If there is
    # only one word, it is not possible to have an alternating feature.
    # Given two words, if there is only one alternating feature
    # then evaluating the words together is no different than evaluating
    # each one in isolation (single form learning).
    # At limit of current understanding, not attempting to set features
    # that alternate could only miss a settable feature if either:
    # * a contrast pair has multiple alternating unset features;
    # * the list of words contains more than two words.
    # :call-seq:
    #   run(words, grammar) -> array
    def run(words, grammar)
      # Create duplicates of the the _words_, to avoid side effects of testing
      # on the original words.
      word_list = words.map(&:dup)
      # Partition the unset features, and attempt to set each
      # non-conflicting feature.
      conflict, no_conflict = partition_unset_features(word_list, grammar)
      test_non_conflicting_features(word_list, grammar, conflict,
                                    no_conflict)
    end

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

    # Test each non-conflicting unset feature, and set it if possible.
    def test_non_conflicting_features(word_list, grammar, conflict, no_conflict)
      set_feature_list = []
      no_conflict.each do |f_uf_instance|
        # Synchronize each input with the lexicon, and then assign any unset
        # input features the value matching their output correspondent.
        # This re-initializes the inputs before each feature test.
        word_list.each(&:sync_with_lexicon!)
        word_list.each(&:match_input_to_output!)
        consistent_values =
          @learn_module.consistent_feature_values(f_uf_instance, word_list,
                                                  conflict, grammar)
        process_consistent_values(consistent_values, f_uf_instance,
                                  set_feature_list)
      end
      set_feature_list
    end
    private :test_non_conflicting_features

    # If the set of consistent values has more than one element, then the
    # target feature cannot be determined at this point, and it returns
    # false. If the set has exactly one element, then the target feature
    # is sent to that (sole) consistent value in the lexicon, and the
    # target feature is added to _set_feature_list_.
    # If there are no consistent values, then an exception is raised.
    def process_consistent_values(consistent_values, f_uf_instance,
                                  set_feature_list)
      if consistent_values.size.zero?
        raise "No feature value for #{f_uf_instance} is consistent."
      end
      return false if consistent_values.size > 1

      f_uf_instance.value = consistent_values.first
      set_feature_list << f_uf_instance
      true
    end
    private :process_consistent_values
  end
end

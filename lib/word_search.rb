# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature_instance'
require 'set'

# Provides a collection of methods for searching a list of words
# with special criteria.
class WordSearch
  # Returns a new instance of WordSearch.
  # :call-seq:
  #   WordSearch.new -> word_search
  def initialize(feat_inst_class: FeatureInstance)
    @feat_inst_class = feat_inst_class
  end

  # Returns the words in +word_list+ that unfaithfully realize
  # the underlying feature instance +uf_feat_inst+.
  # :call-seq:
  #   find_unfaithful(uf_feat_inst, word_list) -> array
  def find_unfaithful(uf_feat_inst, word_list)
    word_list.each_with_object([]) do |word, cwords|
      out_feat_inst = word.out_feat_corr_of_uf(uf_feat_inst)
      next if out_feat_inst.nil?

      cwords << word if uf_feat_inst.value != out_feat_inst.value
    end
  end

  # Returns a hash mapping each morpheme contained in the word list
  # to an array of words from the list that contain that morpheme.
  # The word_list can contain any objects responding to #morphword.
  # :call-seq:
  #   morphemes_to_words(word_list) -> hash
  def morphemes_to_words(word_list)
    m2w_hash = {}
    word_list.each do |word|
      word.morphword.each do |morph|
        m2w_hash[morph] = if m2w_hash.key?(morph)
                            m2w_hash[morph] << word
                          else
                            [word]
                          end
      end
    end
    m2w_hash
  end

  # Returns an array of unset features for the morphemes in the word list.
  def find_unset_features_in_words(word_list, grammar)
    # Build hash of morphemes and the words in the list that contain them
    morph_in_words = morphemes_to_words(word_list)
    # Extract a list of the morphemes in the words (the keys of the hash)
    morpheme_list = morph_in_words.keys
    # Return a list of the unset features for the morphemes
    find_unset_features(morpheme_list, grammar)
  end

  # Returns an array of unset features for the morpheme.
  def find_unset_features_of_morpheme(morpheme, grammar)
    unset_features = []
    uf = grammar.get_uf(morpheme)
    uf.each do |el|
      el.each_feature do |f|
        unset_features << @feat_inst_class.new(el, f) if f.unset?
      end
    end
    unset_features
  end

  # Returns an array of unset features in the morpheme list.
  def find_unset_features(morpheme_list, grammar)
    unset_features = []
    morpheme_list.each do |morph|
      unset_features.concat find_unset_features_of_morpheme(morph, grammar)
    end
    unset_features
  end

  # Finds, within the words of word_list, all of the surface correspondents
  # of the underlying feature instance uf_feat. Return false if the surface
  # correspondents all have the same value; return true otherwise.
  def conflicting_output_values?(uf_feat, word_list)
    # Get output correspondents of the underlying feature
    out_feature_list = word_list.map { |w| w.out_feat_corr_of_uf(uf_feat) }
    # Remove occurrences of nil (from words with no output correspondent)
    out_feature_list = out_feature_list.reject(&:nil?)
    # Count the number of distinct output values for the feature.
    value_set = Set.new
    out_feature_list.each { |feat| value_set.add(feat.value) }
    # If there is more than one feature value present, return true.
    value_set.size > 1
  end
end

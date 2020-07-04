# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature_instance'

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
end

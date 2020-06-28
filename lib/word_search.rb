# frozen_string_literal: true

# Author: Bruce Tesar

# Provides a collection of methods for searching a list of words
# with special criteria.
class WordSearch
  # Returns a new instance of WordSearch.
  # :call-seq:
  #   WordSearch.new -> word_search
  def initialize; end

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
end

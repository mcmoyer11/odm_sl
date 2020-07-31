# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Used to assign a specified value to specified input features of words.
  class InputFeatureAssigner
    # Creates a new assigner.
    # :call-seq:
    #   OTLearn::InputFeatureAssigner.new -> assigner
    def initialize; end

    # Assigns the feature value _assigned_value_ to all input features
    # in the words of _word_list_ that correspond to the underlying
    # feature _uf_finst_.
    # :call-seq:
    #   assign_input_features(uf_finst, assigned_value, word_list) -> nil
    def assign_input_features(uf_finst, assigned_value, word_list)
      uf_el = uf_finst.element
      uf_feat = uf_finst.feature
      word_list.each do |word|
        # Get the corresponding input element of the word; skip this word
        # if it has no input correspondent.
        in_el = word.ui_in_corr(uf_el)
        next if in_el.nil?

        # Get the right feature of the input element, and assign it
        # the given value.
        in_feat = in_el.get_feature(uf_feat.type)
        in_feat.value = assigned_value
        word.eval # re-evaluate the constraint violations
      end
      nil
    end
  end
end

# Author: Bruce Tesar
# 

module OTLearn

  # A contrast set is a collection of words to be processed together.
  # Typically, they are selected so that they jointly express contrasts
  # of the language, the prototypical example being a contrast pair.
  #
  # A contrast set is a container with a few added methods specific
  # to contrast sets.
  class ContrastSet < Array
    # Takes the Enumerable _word_list_, and stores a duplicate (.dup) of each
    # element of _word_list_ as a word in the contrast set.
    def initialize(word_list)
      word_list.each{|word| self << word.dup}
    end

    # Returns a duplicate ContrastSet containing duplicates (.dup) of
    # the words of this contrast set.
    def dup_words
      return ContrastSet.new(self.map { |word| word.dup })
    end

    # Checks each feature of the input of each word in this contrast set.
    # Returns true if any of the features doesn't match the feature value
    # of its underlying correspondent (provided the underlying and input
    # correspondents have been set to a value); returns false otherwise.
    def input_conflicts_with_uf?
      conflict = false
      self.each do |word| # For each word of the contrast set
        word.input.each do |in_el| # For each input element
          in_el.each_feature do |in_feat| # For each input element feature
            # Create the input feature instance
            in_feat_inst = FeatureInstance.new(in_el,in_feat)
            # Get the corresponding uf feature instance
            uf_feat_inst = word.uf_feat_corr_of_in(in_feat_inst)
            # No conflict if either feature is unset
            next if (uf_feat_inst.feature.unset? || in_feat_inst.feature.unset?)
            # Conflict if uf value is not the same as the input value
            conflict = true unless (in_feat_inst.value == uf_feat_inst.value)
          end
        end
      end
      return conflict
    end

    # Returns an array of the morphemes of the contrast set, sorted
    # by order of first appearance in the set. First appearance means
    # taking the words in enumerator order in the contrast set, and
    # for each word taking the morphemes in order of linear precedence
    # in the word.
    def sorted_morpheme_list
      sorted_list = []
      self.each do |word|
        word.morphword.each do |morph|
          sorted_list << morph unless sorted_list.member?(morph)
        end
      end
      return sorted_list
    end

    # Returns a string representing the contrast set in a form appropriate
    # for use as a GraphViz label. The returned string is a concatenation
    # of the graphviz_oriented string representations (.to_gv) of each of
    # the words, separated by newline characters.
    def to_gv
      gv_form = map{|word| word.input.to_gv}
      gv_form.join("\\n") #double backslash so it will appear as '\n' in the .dot file.
    end

  end # class ContrastSet

end # module OTLearn

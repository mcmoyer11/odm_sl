# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/erc_learning'
require 'word_search'

module OTLearn
  # Learns new ERCs (ranking information) for a grammar, based on
  # a set feature instance. It checks words that unfaithfully map
  # the feature instance.
  class ParadigmErcLearning
    # The ERC learner. Default: ErcLearning.new
    attr_accessor :erc_learner

    # The object that searches the given word list. Default: WordSearch.new
    attr_accessor :word_searcher

    # Returns a new paradigm ERC learner.
    # :call-seq:
    #   ParadigmErcLearning.new -> learner
    def initialize
      @erc_learner = ErcLearning.new
      @word_searcher = WordSearch.new
    end

    # Tries to obtain new ERCs from words that unfaithfully map
    # a set feature instance, with respect to the given grammar.
    # Returns true if any new ERCs were added to the grammar,
    # false otherwise.
    # * sfeat - the set feature to be checked
    # * grammar - the grammar to which new ERCs would be added
    # * outputs - the list of outputs for words
    # :call-seq:
    #   run(sfeat, grammar, outputs) -> boolean
    def run(sfeat, grammar, outputs)
      # Collect the outputs containing the set feature's morpheme
      containing_outputs = outputs.find_all do |out|
        out.morphword.include?(sfeat.morpheme)
      end
      # Parse the containing outputs into full words
      words = containing_outputs.map do |out|
        word = grammar.parse_output(out)
        word.match_input_to_output!
      end
      # search for words with unfaithful realizations of the set feature
      unfaith_words = @word_searcher.find_unfaithful(sfeat, words)
      # Run ERC learning
      mrcd = @erc_learner.run(unfaith_words, grammar)
      # Return true if any new ERCs were obtained, false otherwise
      mrcd.any_change?
    end
  end
end

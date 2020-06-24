# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/mrcd'

module OTLearn
  # Learns ERCs (ranking information) based on a word list and
  # an existing grammar. The grammar object passed in to #run
  # is directly updated with any additional winner-loser pairs
  # produced by learning.
  class ErcLearning
    # Returns a new ErcLearning object, using the provided loser selector.
    def initialize(loser_selector, mrcd_class: Mrcd)
      @loser_selector = loser_selector
      @mrcd_class = mrcd_class
    end

    # Runs ERC learning, returning an Mrcd object based on +word_list+
    # and +grammar+.
    # :call-seq:
    #   run(word_list, grammar) -> mrcd
    def run(word_list, grammar)
      mrcd_result = @mrcd_class.new(word_list, grammar, @loser_selector)
      mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
      mrcd_result
    end
  end
end

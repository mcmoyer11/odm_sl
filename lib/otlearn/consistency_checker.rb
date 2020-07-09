# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/mrcd'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

module OTLearn
  # Checks a set of words for collective consistency with a given grammar.
  # MRCD is used to determine consistency; if MRCD can find a ranking that
  # is consistent with the prior ERCs of the grammar and makes each of
  # the words optimal, then the words are collectively consistent with
  # the grammar.
  class ConsistencyChecker
    # Selects informative ERCs; used by Mrcd.
    attr_accessor :loser_selector

    # Returns a new ConsistencyChecker object.
    # :call-seq:
    #   ConsistencyChecker.new -> checker
    #--
    # mrcd_class is a dependency injection used for testing.
    def initialize(mrcd_class: Mrcd)
      @loser_selector = nil
      @mrcd_class = mrcd_class
    end

    # Computes the mismatch input candidate for each output, and tests
    # the set candidates for consistency with the grammar. The mismatching
    # is done separately for each word, i.e., the same unset feature of
    # a morpheme might be assigned different values in the inputs of
    # different words, depending on the outputs of those words.
    # Returns true if the candidates are collectively consistent,
    # false otherwise.
    # :call_seq:
    #   mismatch_consistent?(output_list, grammar) -> boolean
    def mismatch_consistent?(output_list, grammar)
      default_loser_selector(grammar.system) if @loser_selector.nil?
      mismatch_list = output_list.map do |output|
        word = grammar.parse_output(output)
        word.mismatch_input_to_output!
      end
      # Use Mrcd to determine collective consistency.
      mrcd_result = @mrcd_class.new(mismatch_list, grammar, @loser_selector)
      mrcd_result.consistent?
    end

    # Constructs the default loser selector.
    def default_loser_selector(system)
      basic_selector = LoserSelector.new(CompareConsistency.new)
      @loser_selector = LoserSelectorFromGen.new(system, basic_selector)
    end
    private :default_loser_selector
  end
end

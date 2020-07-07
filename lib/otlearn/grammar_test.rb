# frozen_string_literal: true

# Author: Bruce Tesar

require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'
require 'otlearn/grammar_test_result'

module OTLearn
  # A GrammarTest object holds the results of the evaluation of a set
  # of grammatical outputs with respect to a grammar. The tests are initiated
  # by creating a GrammarTest; the constructor takes a list of outputs and
  # a grammar as parameters.
  #
  # Each word is evaluated with a mismatched input: each unset feature is
  # set to the value opposite its surface realization in the word. If
  # a word with a mismatched input is still optimal for the current grammar,
  # then there is nothing more to be learned about the grammar from the word:
  # by output-drivenness, all viable inputs for the word map to the correct
  # output.
  #
  # This class assumes that all of the unset features are binary; see the
  # documentation for Word#mismatch_input_to_output!.
  class GrammarTest
    # Selects an informative loser for a candidate.
    attr_accessor :loser_selector

    # Returns a new GrammarTest object.
    def initialize
      @loser_selector = nil
    end

    # Checks each of the winners to see if they are the sole optimum for
    # their respective inputs. The full input for a winner is constructed
    # by using, for each unset underlying feature, a value that is the
    # *opposite* of the value of the feature for the output correspondent.
    # In other words, adopt values for unset features to maximize the
    # set of disparities. If the candidate with the maximum disparity set
    # is the sole optimum, then output-driven map structure ensures that
    # every other possible candidate for that winner output is also
    # optimal, because it will have a subset of the possible disparities.
    # Thus, none of the remaining unset features matters.
    #
    # Each winner that does not form a sole optimal candidate with a
    # maximally distinct input is added to the failed winner list,
    # accessible by #failed_winners.
    #
    # * output_list - the outputs used to test the grammar
    # * grammar_param - the grammar being tested
    def run(output_list, grammar_param)
      # Duplicate the grammar, so that it isn't affected when the
      # outside grammar is updated by later learning.
      grammar = grammar_param.dup
      # If no loser selector was passed in, build the default one.
      default_loser_selector(grammar.system) if @loser_selector.nil?
      # Initialize lists for failed and successful winners
      @failed_winners = []
      @success_winners = []
      # Parse each output, to create a test instance of the word.
      output_list.each do |output|
        word = grammar.parse_output(output)
        word.mismatch_input_to_output!
        loser = @loser_selector.select_loser(word, grammar.erc_list)
        # If no loser was found, then the word is optimal, and a success.
        if loser.nil?
          @success_winners << word
        else
          @failed_winners << word
        end
      end
      GrammarTestResult.new(@failed_winners, @success_winners, grammar)
    end

    # Constructs the default loser selector.
    def default_loser_selector(system)
      basic_selector = LoserSelector.new(CompareConsistency.new)
      @loser_selector =
        LoserSelectorFromGen.new(system, basic_selector)
    end
    private :default_loser_selector

    # Freeze the test results, so they cannot be accidentally altered later.
    def freeze_results(failed_winners, success_winners, grammar)
      grammar.freeze
      failed_winners.each { |fw| fw.freeze }
      failed_winners.freeze
      success_winners.each { |sw| sw.freeze }
      success_winners.freeze
    end
    private :freeze_results
  end
end

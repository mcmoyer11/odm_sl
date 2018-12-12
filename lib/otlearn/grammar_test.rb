# Author: Bruce Tesar

require_relative '../loserselector_by_ranking'
require_relative 'rcd_bias_low'

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

    # Returns a new GrammarTest, for the provided +winners+, and with
    # respect to the provided +grammar+.
    # * +output_list+ - the outputs used to test the grammar
    # * +grammar+ - the grammar being tested
    # * +loser_selector+ - used for testing (dependency injection).
    def initialize(output_list, grammar, loser_selector: nil)
      @output_list = output_list
      # Dup the grammar, so it can be frozen.
      @grammar = grammar.dup
      @system = grammar.system
      # loser_selector default cannot be put into the parameter list, because
      # the parameter +system+ needs to be computed.
      if loser_selector.nil? then
#        @loser_selector = LoserSelector_by_ranking.new(@system,
#          rcd_class: OTLearn::RcdFaithLow)
        @loser_selector = LoserSelectorExhaustive.new(@system)
      else
        @loser_selector = loser_selector
      end
      # Initialize lists for failed and successful winners
      @failed_winners = []
      @success_winners = []
      check_all
      # Freeze the test results, so they cannot be accidentally altered later.
      @grammar.freeze
      @failed_winners.each {|fw| fw.freeze}
      @failed_winners.freeze
      @success_winners.each {|sw| sw.freeze}
      @success_winners.freeze
    end

    # Returns the grammar used in this test.
    # NOTE: returned object is frozen, and cannot be altered.
    # Create a duplicate to alter it.
    def grammar()
      @grammar
    end
    
    # Returns true if all winners in the winner list are the sole optima
    # for inputs with all unset features set to mismatch the surface of
    # the winner.
    def all_correct?
      @failed_winners.empty?
    end

    # Returns a list of the winners that are *not* the sole optima
    # for inputs with all unset features set to mismatch the surface of
    # the winner.
    def failed_winners()
      @failed_winners
    end

    # Returns a list of the winners that succeeded (are sole optima for
    # inputs with all unset features set to mismatch their surface
    # correspondents.
    def success_winners()
      @success_winners
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
    def check_all
      # Parse each output, to create a test instance of the word.
      @output_list.each do |output|
        word = @grammar.parse_output(output)
        word.mismatch_input_to_output!
        loser = @loser_selector.select_loser(word, @grammar.erc_list)
        # If no loser was found, then the word is optimal, and a success.
        if loser.nil? then
          @success_winners << word
        else
          @failed_winners << word
        end
      end
    end

  end # class GrammarTest
end # module OTLearn

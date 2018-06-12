# Author: Bruce Tesar

require_relative '../loserselector_by_ranking'
require_relative 'data_manip'
require_relative 'rcd_bias_low'

module OTLearn

  # A GrammarTest object holds the results of the evaluation of a set
  # of winners with respect to a grammar. The tests are initiated by
  # creating a GrammarTest; the constructor takes a list of winners and
  # a grammar as parameters.
  #
  # Each winner is a Word, possibly with unset features in the input.
  class GrammarTest

    # Returns a new GrammarTest, for the provided +winners+, and with
    # respect to the provided +grammar+.
    def initialize(winners, grammar, label="NoLabel",
      loser_selector: nil, otlearn_module: OTLearn)
      @label = label
      @system = grammar.system
      # loser_selector default cannot be put into the parameter list, because
      # the parameter +system+ needs to be computed.
      if loser_selector.nil? then
        @loser_selector = LoserSelector_by_ranking.new(system,
          rcd_class: OTLearn::RcdFaithLow)
      else
        @loser_selector = loser_selector
      end
      @otlearn_module = otlearn_module
      # Dup the grammar, so it can be frozen.
      @grammar = grammar.dup
      # Dup the winners, and then adjust their UI correspondence relations
      # to refer to the dup grammar.
      @winners = winners.map{|win| win.dup}
      @winners.each{|win| win.sync_with_grammar!(@grammar)}
      # Initialize lists for failed and successful winners
      @failed_winners = []
      @success_winners = []
      check_all
      # Freeze the test results, so they cannot be accidentally altered later.
      @grammar.freeze
      @winners.each {|win| win.freeze}
      @winners.freeze
      @failed_winners.each {|fw| fw.freeze}
      @failed_winners.freeze
      @success_winners.each {|sw| sw.freeze}
      @success_winners.freeze
    end

    # Returns the label assigned by the constructor.
    def label()
      @label
    end

    # Returns a reference to the linguistic system in use.
    def system
      @system
    end
    protected :system
    
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
    # inputs with all unset features set to mismatch their surface correspondents.
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
    # If some of the features are suprabinary, than all combinations of
    # non-output-matching values for the unset features are tried.
    #
    # Each winner that does not form a sole optimal candidate with a
    # maximally distinct input is added to the failed winner list,
    # accessible by #failed_winners.
    def check_all
      @winners.each do |word|
        @otlearn_module.mismatches_input_to_output(word) do |mismatched_word|
          loser = @loser_selector.select_loser(mismatched_word,
            grammar.erc_list)
          if loser.nil? then
            @success_winners << mismatched_word
          else
            @failed_winners << mismatched_word
          end
        end
      end
    end

  end # class GrammarTest
end # module OTLearn

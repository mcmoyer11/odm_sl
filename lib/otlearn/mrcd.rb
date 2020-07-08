# frozen_string_literal: true

# Author: Bruce Tesar

require 'win_lose_pair'
require 'otlearn/mrcd_single'

module OTLearn
  # An Mrcd object contains the results of applying MultiRecursive Constraint
  # Demotion to a given list of words with respect to a given grammar.
  # The word list and grammar are provided as arguments to the
  # constructor, Mrcd#new. The MRCD algorithm is immediately executed
  # as part of construction of the Mrcd object.
  #
  # Both the word list and the grammar passed to the constructor
  # are duplicated internally prior to use, so that the original objects
  # passed in are not affected by the operations of Mrcd.
  # A method will return a list of the winner-loser pairs constructed and
  # added. If the caller wants to accept the results of MRCD, it should
  # append the list of added winner-loser pairs to its own grammar's support.
  #
  # Once an Mrcd object has been constructed, it should be treated only
  # as a source of results; no further computation can be initiated on
  # the contents. Typically, a caller of Mrcd#new will retain a reference
  # to the original word list, and can obtain via Mrcd#added_pairs the
  # winner-loser pairs that were additionally constructed by MRCD.
  class Mrcd
    # Returns a new Mrcd object containing the results of executing
    # MultiRecursive Constraint Demotion (MRCD) on +word_list+ starting
    # from +grammar+. Both +word_list+ and +grammar+ are duplicated
    # internally before use.
    #
    # ==== Parameters
    #
    # * +word_list+ - list of words to be used as winners (positive data)
    # * +grammar+ - the grammar to use in learning (not modified internally)
    # * +selector+ - loser selection object.
    # * +single_mrcd_class+ - dependency injection parameter for testing.
    #
    # :call-seq:
    #   Mrcd.new(word_list, grammar, selector) -> mrcd
    def initialize(word_list, grammar, selector,
                   single_mrcd_class: OTLearn::MrcdSingle)
      # Make a duplicate copy of each word, so that components of Win-Lose
      # pairs cannot be altered externally.
      @word_list = word_list.map { |word| word.dup }
      # Duplicate the grammar, so that no changes due to MRCD are
      # propagated to the original parameter, and so that the internal
      # grammar cannot be altered externally.
      @grammar = grammar.dup_same_lexicon
      @selector = selector # loser selector
      @single_mrcd_class = single_mrcd_class
      @added_pairs = []
      @any_change = run_mrcd
    end

    # Returns the list of words treated as winners.
    def word_list() @word_list end

    # Returns true if the internal grammar is consistent, false otherwise.
    def consistent?
      @grammar.consistent?
    end

    # The winner-loser pairs added to the grammar by this execution of Mrcd.
    def added_pairs() @added_pairs end

    # Returns true if any change at all was made to the grammar
    # by MRCD. Returns false otherwise.
    def any_change?
      @any_change
    end

    # Runs MRCD on the given word list, making repeated passes through
    # the word list until pass is completed without change to the grammar.
    # Returns true if any change at all is made to the grammar
    # (any new winner-loser pairs are added), and false otherwise.
    def run_mrcd
      any_change = false # initialize grammar change flag
      loop do
        change_on_pass = word_list_pass
        any_change = true if change_on_pass
        # quit if the grammar has become inconsistent
        break unless @grammar.consistent?
        # repeat until a pass with no change
        break unless change_on_pass
      end
      any_change
    end
    private :run_mrcd

    # Runs a single pass through the word list. Each word is treated as
    # a winner, and MRCD (via MrcdSingle) is run on that winner.
    # Any additionally constructed winner-loser pairs are added to both
    # the grammar and the list of added winner-loser pairs.
    # Returns a boolean indicating if the grammar was changed during
    # the class, i.e., if a new winner-loser pair was created and added.
    def word_list_pass
      change = false
      @word_list.each do |winner|
        # run MRCD on the winner
        mrcd_single = @single_mrcd_class.new(winner, @grammar, @selector)
        # retrieve any added winner-loser pairs
        local_added_pairs = mrcd_single.added_pairs
        change = true if local_added_pairs.size > 0
        local_added_pairs.each do |p|
          @added_pairs << p
          @grammar.add_erc(p)
        end
        break unless @grammar.consistent?
      end
      change
    end
    private :word_list_pass
  end
end

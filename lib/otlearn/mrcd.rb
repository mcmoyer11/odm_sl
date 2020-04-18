# Author: Bruce Tesar
#
 
require_relative '../win_lose_pair'
require_relative 'mrcd_single'

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
  #
  # Once an Mrcd object has been constructed, it should be treated only
  # as a source of results; no further computation can be initiated on
  # the contents. Typically, a caller of Mrcd#new will retain a reference
  # to the original word list, and can obtain via Mrcd#added_pairs the
  # winner-loser pairs that were additionally constructed by MRCD.
  class Mrcd

    # Returns a new Mrcd object, with the results of executing
    # MultiRecursive Constraint Demotion (MRCD) to +word_list+ starting
    # from the initial grammar +grammar+. Both +word_list+
    # and +grammar+ are duplicated internally before use. MRCD uses
    # +selector+ as the loser selection object.
    def initialize(word_list, grammar, selector,
        single_mrcd_class: OTLearn::MrcdSingle)
      # Make a duplicate copy of each word, so that components of Win-Lose
      # pairs cannot be altered externally.
      @word_list = word_list.map{|word| word.dup}
      # Duplicate the grammar, so that no changes due to MRCD are
      # propagated to the original parameter, and so that the internal
      # grammar cannot be altered externally.
      @grammar = grammar.dup_same_lexicon
      @selector = selector  # loser selector
      @single_mrcd_class = single_mrcd_class
      @added_pairs = []
      @any_change = run_mrcd
    end
    
    # Returns the list of words treated as winners.
    def word_list() @word_list end

    # Returns the internal grammar used during learning.
    def grammar() @grammar end

    # The winner-loser pairs added to the grammar by this execution of Mrcd.
    def added_pairs() @added_pairs end

    # Returns true if any change at all was made to the grammar
    # by MRCD. Returns false otherwise.
    def any_change?
      @any_change
    end
    
    # Runs MRCD on the given word list, using the given grammar.
    # MRCD is applied to each word of the list in turn; passes are made
    # through the word list until a pass is completed without any change
    # to the grammar.
    # Returns true if any change at all is made to
    # the grammar (any new winner-loser pairs are added).    
    def run_mrcd
      # any_change if grammar changed at all during method execution.
      any_change = false
      begin
        pass_change = false  # any change on this pass through the loop
        @word_list.each do |winner|
          # run MRCD on the winner
          mrcd_single = @single_mrcd_class.new(winner, @grammar, @selector)
          # retrieve any added winner-loser pairs
          local_added_pairs = mrcd_single.added_pairs
          pass_change, any_change = true,true if (local_added_pairs.size > 0)
          local_added_pairs.each do |p|
            @added_pairs << p
            @grammar.add_erc(p)
          end
          break unless @grammar.consistent?
        end
        break unless @grammar.consistent?
      end while pass_change
      return any_change
    end
    protected :run_mrcd
    
  end # class Mrcd

end # module OTLearn

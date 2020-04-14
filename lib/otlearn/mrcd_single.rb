# Author: Bruce Tesar

require_relative "../win_lose_pair"

module OTLearn
  
  # An MrcdSingle object contains the results of applying
  # MultiRecursive Constraint Demotion to a single winner, with respect
  # to a given grammar and a given loser selection routine.
  class MrcdSingle
    
    # Returns a new MrcdSingle object.
    # wl_pair_class - dependency injection parameter for testing.
    def initialize(winner, grammar, selector, wl_pair_class: Win_lose_pair)
      @winner = winner
      @grammar = grammar.dup_same_lexicon
      @added_pairs = []
      @selector = selector
      @wl_pair_class = wl_pair_class
      run_mrcd_single
    end
    
    # Returns the additional winner-loser pairs added to the grammar
    # in order to make the winner optimal.
    def added_pairs
      return @added_pairs
    end
    
    # Returns the winner that MrcdSingle attempted to make optimal.
    def winner
      return @winner
    end
    
    # Returns true if the internal grammar is consistent, false otherwise.
    def consistent?
      return @grammar.consistent?
    end
    
    # Runs MRCD on the winner, using the given grammar and loser selector.
    def run_mrcd_single
      loser = @selector.select_loser(@winner, @grammar.erc_list)
      while !loser.nil? do
        # Create a new WL pair.
        new_pair = @wl_pair_class.new(@winner, loser)
        new_pair.label = @winner.morphword.to_s
        # Add the new pair to the list and the grammar.
        @added_pairs << new_pair
        @grammar.add_erc(new_pair)
        # break out of the loop if the grammar is inconsistent
        break unless @grammar.consistent?
        loser = @selector.select_loser(@winner, @grammar.erc_list)
      end
      return true
    end
    protected :run_mrcd_single
    
  end # class MrcdSingle
  
end # module OTLearn

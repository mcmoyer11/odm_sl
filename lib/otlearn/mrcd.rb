# Author: Bruce Tesar
#
 
require_relative '../most_harmonic'
require_relative '../rcd'
require_relative '../loserselector_by_ranking'

module OTLearn

  # An Mrcd object contains the results of applying MultiRecursive Constraint
  # Demotion to a given list of words with respect to a given hypothesis.
  # The word list and hypothesis are provided as arguments to the
  # constructor, Mrcd#new. The MRCD algorithm is immediately executed
  # as part of construction of the Mrcd object.
  # 
  # Both the word list and the hypothesis passed to the constructor
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
    # MultiRecursive Constraint Demotion (MRCD) to _word_list_ starting
    # from the initial grammar hypothesis _hypothesis_. Both _word_list_
    # and _hypothesis_ are duplicated internally before use. MRCD uses
    # _selector_ as the loser selection object.
    def initialize(word_list, hypothesis, selector)
      # Make a duplicate copy of each word, so that components of Win-Lose
      # pairs cannot be altered externally.
      @word_list = word_list.map{|word| word.dup}
      # Duplicate the hypothesis, so that no changes due to MRCD are
      # propagated to the original parameter, and so that the internal
      # hypothesis cannot be altered externally.
      @hypothesis = hypothesis.dup_same_lexicon
      @selector = selector  # loser selector
      @added_pairs = []
      @any_change = run_mrcd
    end
    
    # Returns the list of words treated as winners.
    def word_list() @word_list end

    # Returns the internal hypothesis used during learning.
    def hypothesis() @hypothesis end

    # The winner-loser pairs added to the hypothesis by this execution of Mrcd.
    def added_pairs() @added_pairs end

    # Returns true if any change at all was made to the hypothesis
    # by MRCD. Returns false otherwise.
    def any_change?
      @any_change
    end
    
    # Runs MRCD on the given word list, using the given hypothesis.
    # MRCD is applied to each word of the list in turn; passes are made
    # through the word list until a pass is completed without any change
    # to the hypothesis.
    # The parameter hypothesis is directly updated during execution.
    # Returns true if any change at all is made to
    # the hypothesis (any new winner-loser pairs are added).    
    def run_mrcd
      # hyp_changed if hypothesis changed during a particular pass through outputs.
      # any_change if hypothesis changed at all during method execution.
      hyp_changed, any_change = true, false
      while hyp_changed do
        hyp_changed = false
        @word_list.each do |winner|
          local_added_pairs = run_mrcd_on_single(winner)
          if (local_added_pairs.size > 0) then
            hyp_changed, any_change = true,true
            @added_pairs.concat(local_added_pairs)
          end
          break unless @hypothesis.consistent?
        end
        break unless @hypothesis.consistent?
      end
      return any_change
    end
    protected :run_mrcd

    # Runs MRCD on _winner_, and returns a list of any additional
    # winner-loser pairs added to the hypothesis.
    def run_mrcd_on_single(winner)
      local_added_pairs = []
      loser = @selector.select_loser(winner, @hypothesis.erc_list)
      # Error-driven processing is complete when no informative losers remain.
      while !loser.nil? do
        # Create a new WL pair.
        new_pair = Win_lose_pair.new(winner, loser)
        new_pair.label = winner.morphword.to_s
        # Add the new pair to the hypothesis.
        local_added_pairs << new_pair
        @hypothesis.add_erc(new_pair)
        break unless @hypothesis.consistent?
        loser = @selector.select_loser(winner, @hypothesis.erc_list)
      end
      return local_added_pairs
    end
    protected :run_mrcd_on_single

  end # class Mrcd

end # module OTLearn

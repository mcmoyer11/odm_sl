# Author: Bruce Tesar
#
 
require_relative 'rcd_bias_low'
require_relative '../most_harmonic'
require_relative '../rubot'
require 'rcd'

module OTLearn

  # An Mrcd object contains the results of applying MultiRecursive Constraint
  # Demotion to a given list of words with respect to a given hypothesis.
  # The word list and hypothesis are provided as arguments to the
  # constructor, Mrcd#new. The MRCD algorithm is immediately executed
  # as part of construction of the Mrcd object. The hypothesis object
  # passed into the constructor is directly updated by MRCD, and will
  # typically have been changed once Mrcd#new is finished.
  #
  # Once an Mrcd object has been constructed, it should be treated only
  # as a source of results; no further computation can be initiated on
  # the contents. Typically, a caller of Mrcd#new will retain a reference
  # to the original word list, and can obtain via Mrcd#added_pairs the
  # winner-loser pairs that were additionally constructed by MRCD.
  class Mrcd

    # Returns a new Mrcd object, with the results of executing
    # MultiRecursive Constraint Demotion (MRCD) to _word_list_ starting
    # from the initial grammar hypothesis _hypothesis_. The _word_list_
    # is duplicated internally, so the internal copy is independent of the list
    # passed as the parameter.
    def initialize(word_list, hypothesis)
      @sys = hypothesis.system
      # Make a duplicate copy of each word, so that components of Win-Lose
      # pairs cannot be altered, regardless of what subsequently happens
      # to the parameter word list (after this method has completed).
      @word_list = word_list.map{|word| word.dup}
      @hypothesis = hypothesis
      @added_pairs = []
      @any_change = run_mrcd
    end

    # Returns the list of words treated as winners.
    def word_list() @word_list end

    # Returns the hypothesis used during learning.
    def hypothesis() @hypothesis end

    # The winner-loser pairs added to the hypothesis by this execution of Mrcd.
    def added_pairs() @added_pairs end

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
      # Set the hypothesis hierarchy using whichever ranking bias is currently
      # desired; the ranking bias is in the method #update().
      @hypothesis.update_grammar {|ercs| update(ercs)}
      # Generate all candidates for the input of the winner.
      @competition = @sys.gen(winner.input)
      loser = select_loser(winner)
      # Error-driven processing is complete when no informative losers remain.
      while !loser.nil? do
        # Create a new WL pair.
        new_pair = Win_lose_pair.new(winner, loser)
        # Set the pair label to the morphword string rep.; done with replace()
        # because the winner-loser pair itself is frozen.
        label = new_pair.label
        label.replace(winner.morphword.to_s)
        # Add the new pair to the hypothesis, and re-calc the hierarchy.
        local_added_pairs << new_pair
        @hypothesis.add_erc(new_pair) {|ercs| update(ercs)}
        break unless @hypothesis.consistent?
        loser = select_loser(winner)
      end
      return local_added_pairs
    end
    protected :run_mrcd_on_single

    # Select an informative loser candidate, if one exists. The selection
    # is done by computing a list of all of the most harmonic candidates
    # with respect to the given hypothesis, using the CTie criterion,
    # and then looking for a member of that list that does not have identical
    # violations to the winner and is not already less harmonic than
    # the winner (CTie makes it possible for two candidates to "tie" as most
    # harmonic even though one is more harmonic than the other, when both
    # have conflicting violations with a third candidate on a stratum). If no
    # appropriate loser exists, nil is returned.
    def select_loser(winner)
      # find the most harmonic candidates
      mh = MostHarmonic.new(@competition, @hypothesis.grammar.hierarchy)
      # select an appropriate most harmonic candidate (if any) to be the loser
      loser = mh.find do |cand|
        if cand.ident_viols?(winner) then
          false # don't select a loser with identical violations
        elsif mh.more_harmonic?(winner, cand, @hypothesis.grammar.hierarchy)
          false # don't select a loser that is already less harmonic
        else
          true
        end
      end
      return loser
    end

    # Returns true if any change at all was made to the hypothesis
    # by MRCD. Returns false otherwise.
    def any_change?
      @any_change
    end
    
    # Calculates the constraint hierarchy for the given WL pairs using
    # the default "as high as possible" RCD ranking bias. This bias could be
    # changed by overriding this method in subclasses.
    def update(wl_pairs)
      Rcd.new(wl_pairs)
    end
    protected :update
    
  end # class Mrcd

  # This is a subclass of Mrcd that uses a "faithfulness-low" ranking
  # bias instead of the default RCD "as high as possible" bias.
  # The interface is identical to Mrcd: a winner list and a hypothesis are
  # given to the constructor, and Mrcd is automatically run.
  class MrcdFaithLow < Mrcd
    # Calculates the constraint hierarchy for the given WL pairs using
    # a faithfulness-low ranking bias.
    def update(wl_pairs)
      RcdFaithLow.new(wl_pairs)
    end
    protected :update
  end

  # This is a subclass of Mrcd that uses a "markedness-low" ranking
  # bias instead of the default RCD "as high as possible" bias. The
  # interface is identical to Mrcd.
  # The interface is identical to Mrcd: a winner list and a hypothesis are
  # given to the constructor, and Mrcd is automatically run.
  class MrcdMarkLow < Mrcd
    # Calculates the constraint hierarchy for the given WL pairs using
    # a markedness-low ranking bias.
    def update(wl_pairs)
      RcdMarkLow.new(wl_pairs)
    end
    protected :update
  end

end # module OTLearn

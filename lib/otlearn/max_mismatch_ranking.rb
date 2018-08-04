# Author: Morgan Moyer

require 'word'
require_relative 'learning_exceptions'
require_relative 'mmr_exceptions'
require_relative 'ranking_learning'

module OTLearn
  
  # MaxMismatchRanking takes a list of outputs of winners that are failing
  # Initial Word Evaluation (where the candidate created using the maximally
  # dissimilar input paired with the output is error tested),
  # but that are consistent with the grammar, in the sense that there exists
  # a ranking consistent with the grammar's support under which the winner
  # succeeds (is optimal).
  # One of the outputs is chosen, and parsed into a word where the input is
  # mismatched with the output. The learner computes the additional ranking
  # information necessary to make the winner successful, and adds that
  # information to the grammar's actual support. The change to the grammar
  # is achieved as a side effect on the grammar passed to the constructor.
  # The returned object contains the other products of the procedure.
  # 
  # This class would typically be invoked when neither single form learning nor
  # contrast pairs are able to make further progress, yet learning is
  # not yet complete, suggesting that a paradigmatic subset relation is present.
  # The learner is making the inductive leap that the failed output, because
  # it is consistent, is likely an actual grammatical output, and it
  # further maximizes the number of inputs mapping to the output by mapping
  # the max mismatch input, thus enforcing greater restrictiveness.
  #
  # This assumes that all of the unset features are binary; see the
  # documentation for Word#mismatch_input_to_output!.
  class MaxMismatchRanking
    
    # Initializes a new object, *and* automatically executes
    # the max mismatch ranking algorithm.
    # * +failed_winner_output_list+ is the list of outputs of *consistent*
    #    failed winners that are candidates for use in MMR.
    # * +grammar+ is the current grammar of the learner.
    # * +language_learner+ included in an exception that is raised.
    # * +learning_module+ - the module containing the method
    #   #ranking_learning.
    #   Used for testing (dependency injection).
    # * +loser_selector+ - object used to select informative losers.
    def initialize(failed_winner_output_list, grammar, language_learner,
        learning_module: OTLearn, loser_selector: nil)
      @grammar = grammar
      @failed_winner_output_list = failed_winner_output_list
      @language_learner = language_learner
      @learning_module = learning_module
      @loser_selector = loser_selector
      # Cannot put the default in the parameter list because of the call
      # to grammar.system.
      if @loser_selector.nil? then
        @loser_selector = LoserSelectorExhaustive.new(grammar.system)
      end
      @newly_added_wl_pairs = []
      @failed_winner = nil
      @changed = false
      # automatically execute MMR
      run_max_mismatch_learning
    end
    
    # Returns the ERC that the algorithm has created
    def newly_added_wl_pairs
      return @newly_added_wl_pairs
    end
    
    # Returns the failed winner that was used with max mismatch ranking.
    def failed_winner
      return @failed_winner
    end
    
    # Returns true if MaxMismatchRanking has found a consistent WL pair
    def changed?
      return @changed
    end
    
    # Executes the Max Mismatch Ranking algorithm.
    # 
    # The learner chooses a single consistent failed winner from the list.
    # For that failed winner, the learner takes the input with all  
    # unset features set opposite their surface value and creates a candidate.
    # Then, MRCD is used to construct the ERCs necessary to make that
    # candidate grammatical.
    # 
    # Returns True if the consistent max mismatch candidate provides
    # new ranking information. Raises an exception if it does not provide new 
    # ranking information.
    def run_max_mismatch_learning
      @failed_winner = choose_failed_winner
      mrcd_result = @learning_module.
        ranking_learning([@failed_winner], @grammar, @loser_selector)
      @changed = mrcd_result.any_change?
      raise MMREx.new(@failed_winner, @language_learner), ("A failed consistent" +
        " winner did not provide new ranking information.") unless @changed
      @newly_added_wl_pairs = mrcd_result.added_pairs
      return @changed
    end
    protected :run_max_mismatch_learning
    
    # Choose, from among the consistent failed winners, the failed winner to
    # use with MMR. Returns a full word with the input initialized so that
    # set features match the lexicon and unset features mismatch the output.
    def choose_failed_winner
      chosen_output = @failed_winner_output_list.first
      chosen_winner = @grammar.system.parse_output(chosen_output, @grammar.lexicon)
      chosen_winner.mismatch_input_to_output!
      return chosen_winner
    end
    protected :choose_failed_winner
    
  end # class MaxMismatchRanking
end # module OTLearn
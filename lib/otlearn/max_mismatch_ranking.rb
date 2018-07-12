# Author: Morgan Moyer
#

require_relative 'data_manip'
require_relative 'learning_exceptions'
require_relative 'mmr_exceptions'
require_relative 'ranking_learning'

module OTLearn
  
 # MaxMismatchRanking takes winners that are failing Initial Word Evaluation
 # (where the candidate created using the maximally dissimilar input paired 
 # with the output is error testing), and creates a winner-loser pair using the 
 # error. Then, this WL pair is added to the learner's support for inconsistency 
 # testing. If the WL pair is consistent with the learner's support, then the learner
 # can assume that this WL pair encodes missing ranking information.
 # If the WL pair is inconsistent, then the learner should attempt to set an
 # underlying feature, using FewestSetFeatures.
 # 
 # This class would typically be invoked when neither single form learning nor
 # contrast pairs are able to make further progress, yet learning is
 # not yet complete, suggesting that a paradigmatic subset relation is present.
  class MaxMismatchRanking
    
    # Initializes a new object, but does _not_ automatically execute
    # the max mismatch ranking algorithm; #run() must be called to do that.
    # * +failed_winner_list+ is the list of *consistent* failed winners that
    #   are candidates for use in MMR.
    # * +grammar+ is the current grammar of the learner.
    def initialize(failed_winner_list, grammar, language_learner)
      @grammar = grammar
      @failed_winner_list = failed_winner_list
      @language_learner = language_learner
      @newly_added_wl_pairs = []
      @failed_winner = nil
      @changed = false
      # dependency injection defaults
      @ranking_learning_module = OTLearn
    end
    
    # Returns the ERC that the algorithm has created
    def newly_added_wl_pairs
      return @newly_added_wl_pairs
    end
    
    # Returns the failed winner that was used with max mismatch ranking.
    # Will necessarily return nil if
    # MaxMismatchRanking#run has not yet been called on this object.
    def failed_winner
      return @failed_winner
    end
    
    # Returns true if MaxMismatchRanking has found a consistent WL pair
    # Will necessarily return false if MaxMismatchRanking#run has not yet
    # been called on this object.
    def changed?
      return @changed
    end
    
    # Assigns a new module to be used as the source of the underlying
    # form learning methods. Used for testing (dependency injection).
    # To be effective, this must be called before #run() is called.
    # TODO: What other methods are provided by the ranking_learning module?
    def ranking_learning_module=(mod)
      @ranking_learning_module = mod
    end
    

    # Executes the Max Mismatch Ranking algorithm.
    # 
    # The learner considers only the first failed winner on the list.
    # For that failed winner, the learner takes the input with all  
    # unset features set opposite their surface value and creates a candidate.
    # Then, MRCD is used to construct the ERCs necessary to make that
    # candidate grammatical.
    # 
    # Returns True if the consistent max mismatch candidate provides
    # new ranking information. Raises an exception if it does not provide new 
    # ranking information.
    def run
      choose_failed_winner
      mrcd_result = nil
      @ranking_learning_module.mismatches_input_to_output(@failed_winner) do |cand|
        mrcd_result = @ranking_learning_module.ranking_learning_mark_low_no_mod([cand], @grammar)
      end
      @newly_added_wl_pairs = mrcd_result.added_pairs
      @changed = mrcd_result.any_change?
      raise MMREx.new(@failed_winner, @language_learner), ("A failed consistent" +
        " winner did not provide new ranking information.") unless @changed
      return @changed
    end
    
    # Choose, from among the consistent failed winners, the failed winner to
    # use with MMR.
    def choose_failed_winner
      @failed_winner = @failed_winner_list.first      
    end
    
  end # class MaxMismatchRanking
end # module OTLearn
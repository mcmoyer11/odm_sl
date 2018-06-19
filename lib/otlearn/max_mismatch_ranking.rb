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
    # * +failed_winner+ is the current winner pulled from the consistent list
    # in the InductionLearning algorithm.
    # * +grammar+ is the current grammar of the learner.
    def initialize(failed_winner, grammar, language_learner)
      @grammar = grammar
      @failed_winner = failed_winner
      @language_learner = language_learner
      @newly_added_wl_pairs = []
      @change = false
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
    def change?
      return @change
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
    # The learner considers only the first failed winner on the list
    # returned by prior_result. The learner takes the input with all  
    # unset features set opposite their surface value and creates a candidate.
    # Then, using the error produced during error testing, the learner creates
    # a winner-loser pair which is added to the support for inconsistency
    # detection.
    # 
    # If the newly added ERC is consistent, then it is added to the support.
    # If it is inconsistent, then the learner pursues the Fewest Set Features
    # algorithm.
    # 
    # Returns True if the consistent max mismatch candidate provides
    # new ranking information. Raises an exception if it does not provide new 
    # ranking information.
    def run
      mrcd_result = nil
      @ranking_learning_module.mismatches_input_to_output(@failed_winner) do |cand|
        mrcd_result = @ranking_learning_module.ranking_learning_mark_low_mrcd([cand], @grammar)
      end
      @newly_added_wl_pairs = mrcd_result.added_pairs
      @change = mrcd_result.any_change?
      raise MMREx.new(@failed_winner, @language_learner), "A failed consistent winner did not provide new ranking information." unless @change
      return @change
    end
    
  end # class MaxMismatchRanking
end # module OTLearn
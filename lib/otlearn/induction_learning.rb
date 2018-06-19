# Author: Morgan Moyer / Bruce Tesar

require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative '../loserselector_by_ranking'
require_relative 'uf_learning'
require_relative 'mrcd'
require_relative 'data_manip'
require_relative 'fewest_set_features'
require_relative 'max_mismatch_ranking'

module OTLearn
  class InductionLearning

    def initialize(word_list, grammar, prior_result, language_learner)
     @word_list = word_list
     @grammar = grammar
     @prior_result = prior_result
     @language_learner = language_learner
     @change = false
     # dependency injection defaults
     @fewest_set_features_class = OTLearn::FewestSetFeatures
     @max_mismatch_ranking_class = OTLearn::MaxMismatchRanking
    end
    
    # Assigns a new object to be used as the source of the fewest set
    # features algorithm. Used for testing (dependency injection).
    # To be effective, this must be called before #run_induction_learning() is called.
    def fewest_set_features_class=(fsf_class)
      @fewest_set_features_class = fsf_class
    end
    
    # Assigns a new object to be used as the source of the max mismatch
    # ranking algorithm. Used for testing (dependency injection).
    # To be effective, this must be called before #run_induction_learning() is called.
    def max_mismatch_ranking_class=(mmr_class)
      @max_mismatch_ranking_class = mmr_class
    end

    # Returns true if induction learning made a change to the grammar,
    # returns false otherwise.
    def change?
      return @change
    end

   # Returns true if anything changed about the grammar
    def run_induction_learning
      # If there are no failed winners, raise an exception, because
      # induction learning shouldn't be called unless there are failed
      # winners to work on.
      if @prior_result.failed_winners.empty? then
        raise RuntimeError.new("InductionLearning invoked with no failed winners.")
      end
      
      # Check failed winners for consistency, and collect the consistent ones
      consistent_list = @prior_result.failed_winners.select do |word|
        @language_learner.mismatch_consistency_check(@grammar, [word]).grammar.consistent?
      end
      # If there are consistent errors, run MMR on one
      if consistent_list.empty?
         # Should call FSF
         fsf = @fewest_set_features_class.new(@word_list, @grammar, @prior_result, @language_learner)
         fsf.run
         @change = fsf.change?
      else
        # Should call MMR on the first member of the list
        mmr = @max_mismatch_ranking_class.new(consistent_list.first, @grammar, @language_learner)
        mmr.run
        @change = mmr.change?
      end
      return @change
    end
    
   end # class Induction_learning
end # module OTLearn

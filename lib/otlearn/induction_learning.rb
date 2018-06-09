# Author: Morgan Moyer / Bruce Tesar

require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative '../loserselector_by_ranking'
require_relative 'uf_learning'
require_relative 'mrcd'
require_relative 'data_manip'
require_relative 'fewest_set_features'

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
     @otlearn_module = OTLearn
    end
    
    # Assigns a new object to be used as the source of the fewest set
    # features algorithm. Used for testing (dependency injection).
    # To be effective, this must be called before #run_induction_learning() is called.
    def fewest_set_features_class=(fsf_class)
      @fewest_set_features_class = fsf_class
    end

    # Resets the module providing the namespace for various learning methods.
    # Used in testing (dependency injection).
    def otlearn_module=(mod)
      @otlearn_module = mod
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
        @otlearn_module.mismatch_consistency_check(@grammar, [word]).grammar.consistent?
      end
      # If there are consistent errors, run MMR on one
      #if consistent_list.empty?
      if true
         # Should call FSF
         fsf = @fewest_set_features_class.new(@word_list, @grammar, @prior_result, @language_learner)
         fsf.run
         @change = fsf.change?
      else
        # Should call MMR on the first member of the list
        consistent_list.each do |c|
          new_ranking_info = run_max_mismatch_ranking(c, @grammar)
          @change = true if new_ranking_info
          break if new_ranking_info
        end
      end
      return @change
    end

    # Returns True if any new ranking information was added, false otherwise
    def run_max_mismatch_ranking(word, grammar)
      max_disparity_list = []
      OTLearn::mismatches_input_to_output(word) {|cand| max_disparity_list << cand }
      winner = max_disparity_list.first 
      #STDERR.puts winner
      OTLearn::ranking_learning_faith_low([winner], grammar)
    end

    protected :run_max_mismatch_ranking
   end #class Induction_learning
end #module OTLearn
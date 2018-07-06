# Author: Morgan Moyer / Bruce Tesar

require_relative 'ranking_learning'
require_relative 'data_manip'
require_relative 'grammar_test'
require_relative 'fewest_set_features'

module OTLearn
  
  # This performs certain inductive learning methods when contrast pair
  # learning fails to fully learn the language. The two inductive methods
  # are Max Mismatch Ranking (MMR) and Fewest Set Features (FSF).
  class InductionLearning

    # Creates the induction learning object, and automatically runs
    # induction learning.
    # * +word_list+ - the list of grammatical words.
    # * +grammar+ - the grammar that learning will use/modify.
    # * +language_learner+ - passed on to +fewest_set_features_class+.new
    # * +learning_module+ - the module containing the method
    #   #mismatch_consistency_check.  Used for testing (dependency injection).
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    # * +fewest_set_features_class+ - the class of object used for fewest set
    #   features.  Used for testing (dependency injection).
    #
    # :call-seq:
    #   InductionLearning.new(word_list, grammar, language_learner) -> obj
    def initialize(word_list, grammar, language_learner,
        learning_module: OTLearn, grammar_test_class: OTLearn::GrammarTest,
        fewest_set_features_class: OTLearn::FewestSetFeatures)
      @outputs = word_list.map{|win| win.output}
      @grammar = grammar
      @language_learner = language_learner
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @fewest_set_features_class = fewest_set_features_class
      @changed = false
      # Test the words to see which ones currently fail
      @word_list = @outputs.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      @prior_result = @grammar_test_class.new(@word_list, @grammar)
      run_induction_learning
      # TODO: change the label below (or eliminate it)
      @test_result = @grammar_test_class.new(@word_list, @grammar, "Minimal UF Learning")
    end
    
    # Returns true if induction learning made a change to the grammar,
    # returns false otherwise.
    def changed?
      return @changed
    end

    # Returns the results of a grammar test after the completion of
    # phonotactic learning.
    def test_result
      @test_result
    end
    
    # Returns true if all words are correctly processed by the grammar;
    # returns false otherwise.
    def all_correct?
      @test_result.all_correct?
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
        @learning_module.mismatch_consistency_check(@grammar, [word]).grammar.consistent?
      end
      # If there are consistent errors, run MMR on one
      #if consistent_list.empty?
      if true
         # Should call FSF
         fsf = @fewest_set_features_class.new(@word_list, @grammar,
           @prior_result, @language_learner)
         @changed = fsf.changed?
      else
        # Should call MMR on the first member of the list
        consistent_list.each do |c|
          new_ranking_info = run_max_mismatch_ranking(c, @grammar)
          @changed = true if new_ranking_info
          break if new_ranking_info
        end
      end
      return @changed
    end
    protected :run_induction_learning

    # Returns True if any new ranking information was added, false otherwise
    def run_max_mismatch_ranking(word, grammar)
      max_disparity_list = []
      @learning_module.mismatches_input_to_output(word) {|cand| max_disparity_list << cand }
      winner = max_disparity_list.first 
      #STDERR.puts winner
      @learning_module.ranking_learning_faith_low([winner], grammar)
    end
    protected :run_max_mismatch_ranking

   end #class Induction_learning
end #module OTLearn
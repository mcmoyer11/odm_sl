# Author: Bruce Tesar

require_relative 'ranking_learning'
require_relative 'grammar_test'

module OTLearn
  
  # Executes phonotactic learning on a list of winners, using the
  # provided grammar. Any effects of learning are realized as side effect
  # changes to the grammar.
  class PhonotacticLearning
    
    # Creates the phonotactic learning object, and automatically
    # runs phonotactic learning.
    # * +winner_list+ - a list of winners (words)
    # * +grammar+ - the grammar that learning will use/modify
    # * +learning_module+ - the source of the MRCD variant
    #   run. Used for testing (dependency injection).
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    #
    # :call-seq:
    #   PhonotacticLearning.new(winner_list, grammar) -> obj
    #   PhonotacticLearning.new(winner_list, grammar, learning_module: module, grammar_test_class: class) -> obj
    def initialize(winner_list, grammar,
        learning_module: OTLearn, grammar_test_class: OTLearn::GrammarTest)
      @winner_list = winner_list
      @grammar = grammar
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @changed = false # default value
      @test_result = nil # should be reset at the end of learning
      run_phonotactic_learning
    end

    # Returns true if phonotactic learning modified the grammar;
    # false otherwise.
    def changed?
      @changed
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
    
    # Actually executes phonotactic learning.
    def run_phonotactic_learning
      @changed = @learning_module.
        ranking_learning_faith_low(@winner_list, @grammar)
      @test_result = @grammar_test_class.new(@winner_list, @grammar, "Phonotactic Learning")
    end
    protected :run_phonotactic_learning
    
  end # class PhonotacticLearning
end # module OTLearn

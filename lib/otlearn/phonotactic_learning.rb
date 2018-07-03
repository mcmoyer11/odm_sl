# Author: Bruce Tesar

require_relative 'ranking_learning'

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
    #
    # :call-seq:
    #   PhonotacticLearning.new(winner_list, grammar) -> obj
    #   PhonotacticLearning.new(winner_list, grammar, learning_module: my_mod) -> obj
    def initialize(winner_list, grammar,
        learning_module: OTLearn)
      @winner_list = winner_list
      @grammar = grammar
      @learning_module = learning_module
      @change = false # default value
      run_phonotactic_learning
    end

    # Returns true if phonotactic learning modified the grammar;
    # false otherwise.
    def changed?
      @change
    end
    
    # Actually executes phonotactic learning.
    def run_phonotactic_learning
      @change = @learning_module.
        ranking_learning_faith_low(@winner_list, @grammar)
    end
    protected :run_phonotactic_learning
    
  end # class PhonotacticLearning
end # module OTLearn

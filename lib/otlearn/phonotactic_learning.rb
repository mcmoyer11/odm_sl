# Author: Bruce Tesar

require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative 'language_learning'

module OTLearn
  
  # Executes phonotactic learning on a list of data outputs, using the
  # provided grammar. Any effects of learning are realized as side effect
  # changes to the grammar.
  class PhonotacticLearning
    # The type of learning step
    attr_accessor :step_type
    
    # Creates the phonotactic learning object, and automatically
    # runs phonotactic learning.
    # * +output_list+ - a list of grammatical outputs
    # * +grammar+ - the grammar that learning will use/modify
    # * +learning_module+ - the source of the MRCD variant
    #   run. Used for testing (dependency injection).
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    #
    # :call-seq:
    #   PhonotacticLearning.new(output_list, grammar) -> obj
    #   PhonotacticLearning.new(output_list, grammar, learning_module: module, grammar_test_class: class) -> obj
    def initialize(output_list, grammar,
        learning_module: OTLearn, grammar_test_class: OTLearn::GrammarTest)
      @output_list = output_list
      @grammar = grammar
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @changed = false # default value
      @step_type = LanguageLearning::PHONOTACTIC
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
      @winner_list = construct_winners
      @changed = @learning_module.
        ranking_learning_faith_low(@winner_list, @grammar)
      @test_result = @grammar_test_class.new(@winner_list, @grammar, "Phonotactic Learning")
    end
    protected :run_phonotactic_learning
    
    # Parse the outputs into winners, with input features matching set
    # lexicon values, and unset features assigned values matching the output.
    def construct_winners
      winner_list = @output_list.map do |out|
        @grammar.system.parse_output(out, @grammar.lexicon)
      end
      winner_list.each do |winner|
        @learning_module.match_input_to_output!(winner)
      end
      return winner_list
    end
    protected :construct_winners

  end # class PhonotacticLearning
end # module OTLearn

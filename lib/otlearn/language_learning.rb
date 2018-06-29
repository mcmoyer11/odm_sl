# Author: Bruce Tesar
#

require_relative 'contrast_pair'
require_relative 'single_form_learning'
require_relative 'contrast_pair_learning'
require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative '../loserselector_by_ranking'
require_relative 'uf_learning'
require_relative 'mrcd'
require_relative 'data_manip'
require_relative '../feature_value_pair'
require_relative 'learning_exceptions'
require_relative 'induction_learning'

module OTLearn

  # A LanguageLearning object instantiates a particular instance of
  # language learning. An instance is created with a set of outputs
  # (the data to be learned from), and a starting grammar (which
  # will likely be altered during the course of learning).
  #
  # The learning proceeds in the following stages, in order:
  # * Phonotactic learning.
  # * Single form learning (one word at a time until no more can be learned).
  # * Repeat until the language is learned or no more progress is made.
  #   * Try a contrast pair; if none are successful, try minimum uf setting.
  #   * If either of these is successful, and the language is not yet learned,
  #     run another round of single form learning.
  # After each stage in which grammar change occurs, the state of
  # the learner is stored and evaluated in a GrammarTest object. These
  # objects are stored in a list, obtainable via #results_list().
  #
  # Learning is initiated upon construction of the object.
  class LanguageLearning

    # Executes learning on +outputs+ with respect to +grammar+, and
    # stores the results in the returned LanguageLearning object.
    def initialize(outputs, grammar)
      @outputs = outputs
      @grammar = grammar
      @results_list = []
      # Convert the outputs to full words, using the grammar,
      # populating the lexicon with the morphemes of the outputs in the process.
      # parse_output() adds the morphemes of the output forms to the lexicon,
      # and constructs a UI correspondence for the input of each word, connecting
      # to the underlying forms of the lexicon.
      @winner_list = @outputs.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      @learning_successful = execute_learning
    end

    # Returns the outputs that were the data for learning.
    def data_outputs() return @outputs end

    # Returns the winners (full candidates) that were used as interpretations of the outputs.
    def data_winners() return @winner_list end

    # Returns the final grammar that was the result of learning.
    def grammar() return @grammar end

    # Returns a boolean indicating if learning was successful.
    def learning_successful?() return @learning_successful end

    # Returns the list of grammar_test objects generated at various stages
    # of learning.
    def results_list()
      @results_list
    end

    # The main, top-level method for executing learning. This method is
    # protected, and called by the constructor #initialize, so learning
    # is automatically executed whenever a LanguageLearning object is
    # created.
    # Returns true if learning was successful, false otherwise.
    def execute_learning
      # Phonotactic learning
      OTLearn::ranking_learning_faith_low(@winner_list, @grammar)
      @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Phonotactic Learning")
      return true if @results_list.last.all_correct?
      # Loop until there is no change.
      # If learning succeeds, the method will return from inside the loop.
      begin
        learning_change = false
        # Single form learning
        sfl = OTLearn::SingleFormLearning.new(@winner_list, @grammar)
        sfl.run
        @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Single Form Learning")
        return true if @results_list.last.all_correct?
        # First, try to learn from a contrast pair
        cpl = OTLearn::ContrastPairLearning.new(@winner_list, @grammar, @results_list.last)
        contrast_pair = cpl.run
        unless contrast_pair.nil?
          @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Contrast Pair Learning")
          return true if @results_list.last.all_correct?
          learning_change = true
        else
          # No suitable contrast pair, so pursue a step of minimal UF learning
          guy = OTLearn::InductionLearning.new(@winner_list, @grammar, @results_list.last, self)
          guy.run_induction_learning
          if guy.change? then
            @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Minimal UF Learning")
            return true if @results_list.last.all_correct?
            learning_change = true
          end
        end
      end while learning_change
      return false # learning failed
    end

    protected :execute_learning

  end # class LanguageLearning
  
end # module OTLearn

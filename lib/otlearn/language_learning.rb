# Author: Bruce Tesar

require_relative 'phonotactic_learning'
require_relative 'single_form_learning'
require_relative 'contrast_pair_learning'
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
  # After each major learning step in which grammar change occurs, an object
  # representing the step is stored. The list of major learning steps
  # is obtainable via #step_list().
  #
  # Learning is initiated upon construction of the object.
  class LanguageLearning

    # Executes learning on +outputs+ with respect to +grammar+, and
    # stores the results in the returned LanguageLearning object.
    def initialize(outputs, grammar,
      phonotactic_learning_class: OTLearn::PhonotacticLearning,
      single_form_learning_class: OTLearn::SingleFormLearning,
      contrast_pair_learning_class: OTLearn::ContrastPairLearning,
      induction_learning_class: OTLearn::InductionLearning)
      @outputs = outputs
      @grammar = grammar
      @phonotactic_learning_class = phonotactic_learning_class
      @single_form_learning_class = single_form_learning_class
      @contrast_pair_learning_class = contrast_pair_learning_class
      @induction_learning_class = induction_learning_class
      @step_list = []
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
    
    # Returns the list of major learning steps taken during learning.
    def step_list() return @step_list end

    # Returns a boolean indicating if learning was successful.
    def learning_successful?() return @learning_successful end

    # The main, top-level method for executing learning. This method is
    # protected, and called by the constructor #initialize, so learning
    # is automatically executed whenever a LanguageLearning object is
    # created.
    # Returns true if learning was successful, false otherwise.
    def execute_learning
      # Phonotactic learning
      pl = @phonotactic_learning_class.new(@winner_list, @grammar)
      @step_list << pl
      return true if pl.all_correct?
      # Loop until there is no change.
      # If learning succeeds, the method will return from inside the loop.
      begin
        learning_change = false
        # Single form learning
        sfl = @single_form_learning_class.new(@winner_list, @grammar)
        @step_list << sfl
        return true if sfl.all_correct?
        # Contrast pair learning
        cpl = @contrast_pair_learning_class.new(@winner_list, @grammar)
        if cpl.changed?
          @step_list << cpl
          return true if cpl.all_correct?
          learning_change = true
        else
          # No suitable contrast pair, so pursue a step of FSF learning
          il = @induction_learning_class.new(@winner_list, @grammar, self)
          if il.changed? then
            @step_list << il
            return true if il.all_correct?
            learning_change = true
          end
        end
      end while learning_change
      return false # learning failed
    end
    protected :execute_learning

  end # class LanguageLearning  
end # module OTLearn

# Author: Bruce Tesar

require_relative 'phonotactic_learning'
require_relative 'single_form_learning'
require_relative 'contrast_pair_learning'
require_relative 'induction_learning'
require_relative '../loser_selector_exhaustive'
require_relative '../loserselector_by_ranking'
require_relative 'rcd_bias_low'

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
  #   * Try a contrast pair; if none are successful, try induction learning.
  #   * If either of these is successful, and the language is not yet learned,
  #     run another round of single form learning.
  # After each major learning step in which grammar change occurs, an object
  # representing the step is stored. The list of major learning steps
  # is obtainable via #step_list().
  #
  # Learning is initiated upon construction of the object.
  #
  # ===References
  #
  # Tesar 2014. <em>Output-Driven Phonology</em>.
  class LanguageLearning
    # Pre-defined type constants
    PHONOTACTIC = :phonotactic
    SINGLE_FORM = :single_form
    CONTRAST_PAIR = :contrast_pair
    INDUCTION = :induction

    # Constructs a language learning simulation object, and automatically runs
    # the simulation upon objection construction.
    # * +output_list+ - the winners considered to form contrast pairs
    # * +grammar+ - the current grammar (learning may alter it).
    # The four labeled parameters are the classes of the major learning steps,
    # and are used for testing (dependency injection).
    # * +phonotactic_learning_class+
    # * +single_form_learning_class+
    # * +contrast_pair_learning_class+
    # * +induction_learning_class+
    #
    # :call-seq:
    #   LanguageLearning.new(output_list, grammar) -> obj
    #   LanguageLearning.new(output_list, grammar, phonotactic_learning_class: class,
    #   single_form_learning_class: class, contrast_pair_learning_class: class,
    #   induction_learning_class: class) -> obj
    def initialize(output_list, grammar,
        phonotactic_learning_class: OTLearn::PhonotacticLearning,
        single_form_learning_class: OTLearn::SingleFormLearning,
        contrast_pair_learning_class: OTLearn::ContrastPairLearning,
        induction_learning_class: OTLearn::InductionLearning,
        loser_selector: nil)
      @output_list = output_list
      @grammar = grammar
      @phonotactic_learning_class = phonotactic_learning_class
      @single_form_learning_class = single_form_learning_class
      @contrast_pair_learning_class = contrast_pair_learning_class
      @induction_learning_class = induction_learning_class
      @loser_selector = loser_selector
      # the default value of @loser_selector
      if @loser_selector.nil? then
#        @loser_selector = LoserSelector_by_ranking.new(@grammar.system, rcd_class: OTLearn::RcdFaithLow)
        @loser_selector = LoserSelectorExhaustive.new(@grammar.system)
      end
      @step_list = []
      @learning_successful = execute_learning
    end

    # Returns the outputs that were the data for learning.
    def data_outputs() return @output_list end

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
      pl = @phonotactic_learning_class.new(@output_list, @grammar,
        loser_selector: @loser_selector)
      @step_list << pl
      return true if pl.all_correct?
      # Loop until there is no change.
      # If learning succeeds, the method will return from inside the loop.
      begin
        learning_change = false
        # Single form learning
        begin
          sfl = @single_form_learning_class.new(@output_list, @grammar,
            loser_selector: @loser_selector)
        rescue RuntimeError => ex
          # TODO: add a learning step to the list containing info about the
          # raised exception, so it can appear in the output file.
          STDERR.puts "Error with #{@grammar.label}: " + ex.to_s
          return
        end
        @step_list << sfl
        return true if sfl.all_correct?
        # Contrast pair learning
        cpl = @contrast_pair_learning_class.new(@output_list, @grammar,
          loser_selector: @loser_selector)
        @step_list << cpl
        if cpl.changed?
          return true if cpl.all_correct?
          learning_change = true
        else
          # No suitable contrast pair, so pursue a step of Induction learning
          il = @induction_learning_class.
            new(@output_list, @grammar, self, loser_selector: @loser_selector)
          @step_list << il
          if il.changed? then
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

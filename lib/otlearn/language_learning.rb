# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/phonotactic_learning'
require 'otlearn/single_form_learning'
require 'otlearn/contrast_pair_learning'
require 'otlearn/induction_learning'
require 'otlearn/rcd_bias_low'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

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

    # Indicates phontactic learning stage
    PHONOTACTIC = :phonotactic
    # Indicates single form learning stage
    SINGLE_FORM = :single_form
    # indicates contrast pair learning stage
    CONTRAST_PAIR = :contrast_pair
    # indicates induction learning stage
    INDUCTION = :induction

    # Constructs a language learning simulation object, and automatically runs
    # the simulation upon objection construction.
    # * +output_list+ - the winners considered to form contrast pairs
    # * +grammar+ - the current grammar (learning may alter it).
    # * +loser_selector+ - object used for loser selection; defaults to
    #   a loser selector using CompareConsistency.
    #--
    # The following labeled parameters are the classes of the major learning
    # steps, and are used for testing (dependency injection).
    # * +phonotactic_learning_class+
    # * +single_form_learning_class+
    # * +contrast_pair_learning_class+
    # * +induction_learning_class+
    #++
    # :call-seq:
    #   LanguageLearning.new(output_list, grammar) -> languagelearning
    def initialize(output_list, grammar, loser_selector: nil,
          phonotactic_learning_class: OTLearn::PhonotacticLearning,
          single_form_learning_class: OTLearn::SingleFormLearning,
          contrast_pair_learning_class: OTLearn::ContrastPairLearning,
          induction_learning_class: OTLearn::InductionLearning)
      @output_list = output_list
      @grammar = grammar
      @phonotactic_learning_class = phonotactic_learning_class
      @single_form_learning_class = single_form_learning_class
      @contrast_pair_learning_class = contrast_pair_learning_class
      @induction_learning_class = induction_learning_class
      @loser_selector = loser_selector
      # the default value of @loser_selector
      if @loser_selector.nil?
        basic_selector = LoserSelector.new(CompareConsistency.new)
        @loser_selector = LoserSelectorFromGen.new(grammar.system, basic_selector)
      end
      @step_list = []
      @learning_successful = execute_learning
    end

    # Returns the outputs that were the data for learning.
    def data_outputs
      @output_list
    end

    # Returns the final grammar that was the result of learning.
    def grammar
      @grammar
    end

    # Returns the list of major learning steps taken during learning.
    def step_list
      @step_list
    end

    # Returns a boolean indicating if learning was successful.
    def learning_successful?
      @learning_successful
    end

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
      false # learning failed
    end
    protected :execute_learning
  end
end

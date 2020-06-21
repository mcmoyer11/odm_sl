# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/phonotactic_learning'
require 'otlearn/single_form_learning'
require 'otlearn/contrast_pair_learning'
require 'otlearn/induction_learning'
require 'otlearn/error_step'
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
    # The final grammar that was the result of learning.
    attr_reader :grammar

    # The list of major learning steps taken during learning.
    attr_reader :step_list

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
          phonotactic_learning_class: PhonotacticLearning,
          single_form_learning_class: SingleFormLearning,
          contrast_pair_learning_class: ContrastPairLearning,
          induction_learning_class: InductionLearning)
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
        @loser_selector = LoserSelectorFromGen.new(grammar.system,
                                                   basic_selector)
      end
      @step_list = []
      @learning_successful = error_protected_execution
    end

    # Returns a boolean indicating if learning was successful.
    def learning_successful?
      @learning_successful
    end

    # Calls the main learning procedure, #execute_learning, within
    # a block so that it can rescue a RuntimeError if it arises.
    # Returns true if learning was successful, false otherwise.
    # If a RuntimeError was raised, learning was not successful.
    def error_protected_execution
      success_boolean = false
      begin
        success_boolean = execute_learning
      rescue RuntimeError => e
        msg = "Error with #{@grammar.label}: #{e}"
        @step_list << ErrorStep.new(msg)
        warn msg
      rescue LearnEx => e
        msg1 = @grammar.label
        msg2 = 'FSF: more than one matching feature passes error testing.'
        # Report the feature-value-pairs which are causing learning
        # to crash.
        msg3 = 'The following feature-value pairs pass'
        msg4 = e.consistent_feature_value_list.to_s
        msg = "#{msg1}: #{msg2}\n#{msg3}:\n#{msg4}"
        @step_list << ErrorStep.new(msg)
        warn msg
      rescue MMREx => e
        msg1 = @grammar.label
        msg2 = "MMR: #{e.message}"
        msg3 = "Failed Winner: #{e.failed_winner}"
        msg = "#{msg1}: #{msg2}\n#{msg3}"
        @step_list << ErrorStep.new(msg)
        warn msg
      end
      success_boolean
    end
    private :error_protected_execution

    # The main, top-level method for executing learning. This method is
    # protected, and called by the constructor #initialize, so learning
    # is automatically executed whenever a LanguageLearning object is
    # created.
    # Returns true if learning was successful, false otherwise.
    def execute_learning
      # Phonotactic learning
      pl = @phonotactic_learning_class\
           .new(@output_list, @grammar, loser_selector: @loser_selector)
      @step_list << pl
      return true if pl.all_correct?

      # Loop until there is no change.
      # If learning succeeds, the method will return from inside the loop.
      loop do
        # Single form learning
        sfl = @single_form_learning_class\
              .new(@output_list, @grammar, loser_selector: @loser_selector)
        @step_list << sfl
        break if sfl.all_correct?

        # Contrast pair learning
        cpl = @contrast_pair_learning_class\
              .new(@output_list, @grammar, loser_selector: @loser_selector)
        @step_list << cpl
        break if cpl.all_correct?

        next if cpl.changed?

        # No suitable contrast pair, so pursue a step of Induction learning
        il = @induction_learning_class\
             .new(@output_list, @grammar, loser_selector: @loser_selector)
        @step_list << il
        break if il.all_correct?

        # if no change has occurred on this iteration, then learning
        # has failed.
        break unless il.changed?
      end
      # the last step indicates if learning was ultimately successful
      @step_list[-1].all_correct?
    end
    private :execute_learning
  end
end

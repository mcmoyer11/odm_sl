# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/phonotactic_learning'
require 'otlearn/single_form_learning'
require 'otlearn/contrast_pair_learning'
require 'otlearn/induction_learning'
require 'otlearn/error_step'
require 'otlearn/learning_result'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

module OTLearn
  # A LanguageLearning object instantiates a particular instance of
  # language learning. Learning is executed via the method #learn,
  # given a set of outputs (the data to be learned from), and
  # a starting grammar (which will likely be altered
  # during the course of learning).
  # The method #learn returns a learning result object.
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
  # is obtainable from the learning result via #step_list.
  #
  # ===References
  #
  # Tesar 2014. <em>Output-Driven Phonology</em>.
  class LanguageLearning
    # Phonotactic learner
    attr_accessor :phonotactic_learning_class

    # Single-form learner
    attr_accessor :single_form_learning_class

    # Contrast pair learner
    attr_accessor :contrast_pair_learning_class

    # Induction learner
    attr_accessor :induction_learning_class

    # Loser selector for forming WL pairs; default value is
    # an object of class CompareConsistency.
    attr_accessor :loser_selector

    # Constructs a language learning simulation object.
    # :call-seq:
    #   LanguageLearning.new -> language_learning
    #--
    # +warn_output+ is a dependency injection used for testing. It is
    # the IO channel to which warnings are written (normally $stderr).
    def initialize(warn_output: $stderr)
      # Set the default values for the learning step objects
      @phonotactic_learning_class = PhonotacticLearning
      @single_form_learning_class = SingleFormLearning
      @contrast_pair_learning_class = ContrastPairLearning
      @induction_learning_class = InductionLearning
      @loser_selector = nil # set in #learn
      # The default output channel for warnings is $stderr.
      @warn_output = warn_output
    end

    # Constructs the default loser selector.
    def default_loser_selector(system)
      basic_selector = LoserSelector.new(CompareConsistency.new)
      @loser_selector =
        LoserSelectorFromGen.new(system, basic_selector)
    end
    private :default_loser_selector

    # Runs the learning simulation, and returns a learning result object.
    # :call-seq:
    #   learn(output_list, grammar) -> learning_result
    def learn(output_list, grammar)
      # step_list is an instance variable so that it remains easily
      # accessible if an exception is raised, and then caught by
      # #error_protected_execution.
      @step_list = []
      default_loser_selector(grammar.system) if @loser_selector.nil?
      error_protected_execution(grammar.label) do
        execute_learning(output_list, grammar)
      end
      OTLearn::LearningResult.new(@step_list, grammar)
    end

    # The main, top-level method for executing learning. This method is
    # protected, and called by the constructor #initialize, so learning
    # is automatically executed whenever a LanguageLearning object is
    # created.
    # Returns true if learning was successful, false otherwise.
    def execute_learning(output_list, grammar)
      # Phonotactic learning
      pl = @phonotactic_learning_class.new
      pl_step = pl.run(output_list, grammar)
      @step_list << pl_step
      return true if pl_step.all_correct?

      # Loop until there is no change.
      # If learning succeeds, the method will return from inside the loop.
      loop do
        # Single form learning
        sfl = @single_form_learning_class.new
        sfl_step = sfl.run(output_list, grammar)
        @step_list << sfl_step
        break if sfl_step.all_correct?

        # Contrast pair learning
        cpl = @contrast_pair_learning_class.new
        cpl_step = cpl.run(output_list, grammar)
        @step_list << cpl_step
        break if cpl_step.all_correct?

        next if cpl_step.changed?

        # No suitable contrast pair, so pursue a step of Induction learning
        il = @induction_learning_class.new
        il.run(output_list, grammar)
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

    # Calls provided block, and rescues an exception if one arises.
    # Returns the value returned by block if no exception is raised,
    # otherwise it returns the value returned by the exception handler.
    def error_protected_execution(label)
      yield
    rescue RuntimeError => e
      handle_exception(rterror_msg(e, label))
    rescue LearnEx => e
      handle_exception(learnex_msg(e, label))
    rescue MMREx => e
      handle_exception(mmrex_msg(e, label))
    end
    private :error_protected_execution

    # Handles an exception by creating a new error step, adding it
    # to the step list, writing a warning to the warning output
    # channel, and returning false (indicating learning failed).
    def handle_exception(msg)
      @step_list << ErrorStep.new(msg)
      @warn_output.puts msg # write to the warning output channel
      false # exception means learning has failed
    end
    private :handle_exception

    # Returns the warning message for a RuntimeError exception
    # raised during learning.
    def rterror_msg(exception, label)
      "Error with #{label}: #{exception}"
    end
    private :rterror_msg

    # Returns the warning message for a LearnEx exception, which is
    # raised by FewestSetFeatures (FSF) when more than one unset
    # feature can resolve inconsistency for a word on its own (the learner
    # currently doesn't know how to choose).
    def learnex_msg(exception, label)
      msg1 = 'FSF: more than one matching feature passes error testing.'
      # Report the feature-value-pairs which are causing learning
      # to crash.
      msg2 = 'The following feature-value pairs pass'
      msg3 = exception.consistent_feature_value_list.to_s
      "#{label}: #{msg1}\n#{msg2}:\n#{msg3}"
    end
    private :learnex_msg

    # Returns the warning message for a MMREx exception, which is
    # raised by MaxMismatchRanking (MMR).
    def mmrex_msg(exception, label)
      msg1 = "MMR: #{exception.message}"
      msg2 = "Failed Winner: #{exception.failed_winner}"
      "#{label}: #{msg1}\n#{msg2}"
    end
    private :mmrex_msg
  end
end

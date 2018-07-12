# Author: Bruce Tesar/Morgan Moyer
#

require_relative 'contrast_pair'
require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative '../loserselector_by_ranking'
require_relative 'uf_learning'
require_relative 'mrcd'
require_relative 'data_manip'
require_relative '../feature_value_pair'
require_relative 'learning_exceptions'
require_relative 'language_learning'
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
  # This file is designed to test implementing Morgan's new solution into the 
  # existing code as part of the decision 
  class LanguageLearningMMR < LanguageLearning

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
      # Single form UF learning
      run_single_forms_until_no_change(@winner_list, @grammar)
      @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Single Form Learning")
      return true if @results_list.last.all_correct?
      # Pursue further learning until the language is learned, or no
      # further improvement is made.
      learning_change = true
      while learning_change
        learning_change = false
        # First, try to learn from a contrast pair
        contrast_pair = run_contrast_pair(@winner_list, @grammar, @results_list.last)
        unless contrast_pair.nil?
          @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Contrast Pair Learning")
          learning_change = true
        else 
          # Go for induction learning
          guy = OTLearn::InductionLearning.new(@winner_list, @grammar, @results_list.last, self)
          guy.run_induction_learning
          #
          #
          #STDERR.puts guy.flkjasdf;l
          
          learning_change = true if guy.change?
          # TODO: the label to GrammarTest should have some indication of
          # the *kind* of induction learning that was performed (FSF vs. MMR).
          @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Induction Learning")
        end
        # If no change resulted from a contrast pair or from minimal uf learning,
        # no further learning is currently possible, so break out of the loop.
        # Otherwise, check to see if the change completed learning.
        break unless learning_change
        return true if @results_list.last.all_correct?
        # Follow up with another round of single form learning
        change_on_single_forms = run_single_forms_until_no_change(@winner_list, @grammar)
        if change_on_single_forms then
          @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Single Form Learning")
          return true if @results_list.last.all_correct?
        end
      end
      # Return boolean indicating if learning was successful.
      # This should be false, because a "true" would have triggered an earlier
      # return from this method.
      fail if @results_list.last.all_correct?
      return @results_list.last.all_correct?
    end

  end # class LanguageLearning
end # module OTLearn

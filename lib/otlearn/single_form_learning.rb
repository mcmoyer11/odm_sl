# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/grammar_test'
require 'otlearn/language_learning'
require 'otlearn/single_form_step'
require 'otlearn/ranking_learning'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

module OTLearn
  # This processes all of the outputs in the grammatical output list, one at a
  # time in order, with respect to a grammar. Any results of learning are
  # realized as side effect changes to the grammar.
  class SingleFormLearning
    # Creates a new single form learner.
    #--
    # loser_selector, learning_module and gtest_class are
    # dependency injections used for testing.
    # * learning_module - the module containing several methods used
    #   for learning: #mismatch_consistency_check,
    #   #set_uf_values, and #new_rank_info_from_feature.
    #++
    # :call-seq:
    #   SingleFormLearning.new -> singleformlearner
    def initialize(loser_selector: nil, learning_module: OTLearn,
                   gtest_class: GrammarTest)
      @gtest_class = gtest_class
      @learning_module = learning_module
      @loser_selector = loser_selector
    end

    # Runs single form learning, and returns a single form learning step.
    # :call-seq:
    #   run(output_list, grammar) -> step
    def run(output_list, grammar)
      default_loser_selector(grammar) if @loser_selector.nil?
      changed = false
      loop do
        grammar_changed_on_pass = false
        output_list.each do |output|
          grammar_changed_on_winner = process_winner(output, output_list,
                                                     grammar)
          grammar_changed_on_pass = true if grammar_changed_on_winner
        end
        changed = true if grammar_changed_on_pass
        break unless grammar_changed_on_pass
      end
      test_result = @gtest_class.new(output_list, grammar)
      SingleFormStep.new(test_result, changed)
    end

    # Processes a winner output for new information about the grammar.
    # * Attempt to set each unset feature of the winner.
    # * For each newly set feature, check for new non-phonotactic ranking
    #   information.
    # Returns true if the grammar was changed by processing the winner,
    # false otherwise.
    def process_winner(output, output_list, grammar)
      # Attempt to set each unset feature of winner.
      winner = grammar.parse_output(output)
      set_feature_list = @learning_module.set_uf_values([winner], grammar)
      # (re)construct the winner list (to reflect any just-set features)
      winner_list = output_list.map do |out|
        grammar.parse_output(out)
      end
      # For each newly set feature, check words unfaithfully mapping that
      # feature for new ranking information.
      set_feature_list.each do |set_f|
        @learning_module\
          .new_rank_info_from_feature(grammar, winner_list, set_f,
                                      loser_selector: @loser_selector)
      end
      # If no features were set, then the grammar did not change.
      # Otherwise, the grammar did change.
      !set_feature_list.empty?
    end
    private :process_winner

    # Cannot put the default in the parameter list because of the call
    # to grammar.system.
    def default_loser_selector(grammar)
      basic_selector = LoserSelector.new(CompareConsistency.new)
      @loser_selector = LoserSelectorFromGen.new(grammar.system,
                                                 basic_selector)
    end
    private :default_loser_selector

    # The following code was once part of #process_winner, and made
    # a difference when loser selection was done with inconsistency
    # detection over all competitors. You might want to revive it as
    # a separate method when investigating different loser selection
    # strategies, but it will need to be reworked, for instance
    # .ranking_learning() likely no longer exists.
    #
    # # Check the winner to see if it is the sole optimum for
    # # the matched input; if not, more ranking info is gained.
    # winner.match_input_to_output!
    # new_ranking_info =
    #   @learning_module.ranking_learning([winner], @grammar, @loser_selector)
    # change_on_winner = true if new_ranking_info.any_change?
  end
end

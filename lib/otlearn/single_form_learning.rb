# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/grammar_test'
require 'otlearn/data_manip'
require 'otlearn/language_learning'
require 'otlearn/ranking_learning'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

module OTLearn
  # This processes all of the outputs in the grammatical output list, one at a
  # time in order, with respect to a grammar. Any results of learning are
  # realized as side effect changes to the grammar.
  class SingleFormLearning
    # The type of learning step
    attr_accessor :step_type

    # The list of outputs used for learning.
    attr_reader :output_list

    # The grammar resulting from this run of single form learning.
    attr_reader :grammar

    # Grammar test result after the completion of single form learning.
    attr_reader :test_result

    # Creates the object, and automatically runs single form learning.
    # * +output_list+ - the list of all grammatical outputs.
    # * +grammar+ - the grammar that learning will modify.
    # * +loser_selector+ - selects losers for ranking learning; defaults to
    #   a loser selector using CompareConsistency.
    #--
    # learning_module and grammar_test_class are dependency injections used
    # for testing.
    # * +learning_module+ - the module containing several methods used
    #   for learning: #ranking_learning, #mismatch_consistency_check,
    #   #set_uf_values, and #new_rank_info_from_feature.
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar.
    #++
    #
    # :call-seq:
    #   SingleFormLearning.new(output_list, grammar) -> singleformlearner
    def initialize(output_list, grammar, loser_selector: nil,
                   learning_module: OTLearn,
                   grammar_test_class: OTLearn::GrammarTest)
      @output_list = output_list
      @grammar = grammar
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      # Cannot put the default in the parameter list because of the call
      # to grammar.system.
      if loser_selector.nil?
        basic_selector = LoserSelector.new(CompareConsistency.new)
        @loser_selector = LoserSelectorFromGen.new(grammar.system,
                                                   basic_selector)
      else
        @loser_selector = loser_selector
      end
      @step_type = SINGLE_FORM
      @changed = false
      run_single_form_learning
    end

    # Returns true if single form learning changed the grammar; false otherwise.
    def changed?
      @changed
    end

    # Returns true if all words are correctly processed by the grammar;
    # returns false otherwise.
    def all_correct?
      @test_result.all_correct?
    end

    # Passes repeatedly through the list of outputs until a pass is made
    # with no changes to the grammar. On a given pass, each output is
    # processed for new information.
    # Returns true if the grammar was changed at all, false otherwise.
    def run_single_form_learning
      begin
        grammar_changed_on_pass = false
        @output_list.each do |output|
          grammar_changed_on_winner = process_winner(output)
          grammar_changed_on_pass = true if grammar_changed_on_winner
        end
        @changed = true if grammar_changed_on_pass
      end while grammar_changed_on_pass
      @test_result = @grammar_test_class.new(@output_list, @grammar)
      changed?
    end
    private :run_single_form_learning

    # Processes a winner output for new information about the grammar.
    # * It checks the winner with a mismatched input for consistency: if
    #   the mismatched winner is consistent, then inconsistency detection
    #   won't set any features, so don't bother. A mismatched input is one
    #   in which each unset feature is assigned the value opposite its
    #   surface realization in the winner.
    # * If the mismatched input winner is inconsistent, attempt to set each
    #   unset feature of the winner.
    # * For each newly set feature, check for new non-phonotactic ranking
    #   information.
    #
    # Returns true if the grammar was changed by processing the winner,
    # false otherwise.
    #--
    # TODO: spin #process_winner off into a separate class.
    def process_winner(output)
      change_on_winner = false
      winner = @grammar.parse_output(output)
      winner.match_input_to_output!
      # Check the winner to see if it is the sole optimum for
      # the matched input; if not, more ranking info is gained.
      # TODO: several languages aren't learned if this step isn't taken, if
      #       loser selection by ranking is used; if exhaustive loser selection
      #       is used, this extra ranking info check doesn't seem to be needed.
      # new_ranking_info =
      #   @learning_module.ranking_learning([winner], @grammar, @loser_selector)
      # change_on_winner = true if new_ranking_info.any_change?
      # ===
      # Check the mismatched input for consistency. Only attempt to set
      # features in the winner if the mismatched winner is inconsistent.
      consistency_result =
        @learning_module.mismatch_consistency_check(@grammar, [winner])
      unless consistency_result.grammar.consistent?
        # Attempt to set each unset feature of winner,
        # returning a list of newly set features
        set_feature_list = @learning_module.set_uf_values([winner], @grammar)
        # (re)construct the winner list (to reflect any just-set features)
        winner_list = @output_list.map do |out|
          @grammar.parse_output(out)
        end
        # For each newly set feature, check words unfaithfully mapping that
        # feature for new ranking information.
        set_feature_list.each do |set_f|
          @learning_module\
            .new_rank_info_from_feature(@grammar, winner_list, set_f,
                                        loser_selector: @loser_selector)
        end
        change_on_winner = true unless set_feature_list.empty?
      end
      change_on_winner
    end
    protected :process_winner
  end
end

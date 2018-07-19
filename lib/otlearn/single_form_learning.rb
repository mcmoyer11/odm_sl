# Author: Bruce Tesar
#

require_relative "./grammar_test"
require_relative "./data_manip"
require_relative 'language_learning'

module OTLearn
  
  # This processes all of the outputs in the grammatical output list, one at a
  # time in order, with respect to a grammar. Any results of learning are
  # realized as side effect changes to the grammar.
  class SingleFormLearning
    # The type of learning step
    attr_accessor :step_type
    
    # Creates the object, and automatically runs single form learning.
    # * +output_list+ - the list of all grammatical outputs.
    # * +grammar+ - the grammar that learning will modify.
    # * +learning_module+ - the module containing several methods used
    #   for learning: #ranking_learning_faith_low, #mismatch_consistency_check,
    #   #set_uf_values, and #new_rank_info_from_feature.
    #   Used for testing (dependency injection).
    # * +grammar_test_class+ - the class of object used for testing
    #   words for learning errors. Used for testing (dependency injection).
    #
    # :call-seq:
    #   SingleFormLearning.new(output_list, grammar) -> obj
    #   SingleFormLearning.new(output_list, grammar, learning_module: module, grammar_test_class: class) -> obj
    def initialize(output_list, grammar, learning_module: OTLearn,
        grammar_test_class: OTLearn::GrammarTest)
      @output_list = output_list
      @grammar = grammar
      @otlearn_module = learning_module
      @error_test_class = grammar_test_class
      @changed = false
      @step_type = LanguageLearning::SINGLE_FORM
      @winner_list = @output_list.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      run_single_form_learning
      @test_result = @error_test_class.new(@winner_list, @grammar)
    end
    
    # The list of winner words used for learning.
    def winner_list
      @winner_list
    end
    
    # The grammar resulting from this run of single form learning.
    def grammar
      @grammar
    end

    # Returns true if single form learning changed the grammar; false otherwise.
    def changed?
      return @changed
    end
    
    # Returns the results of a grammar test after the completion of
    # single form learning.
    def test_result
      @test_result
    end

    # Returns true if all words are correctly processed by the grammar;
    # returns false otherwise.
    def all_correct?
      @test_result.all_correct?
    end
    
# Processes the winners of #winners for new grammatical information.
    # 
    # Passes repeatedly through the list of winners until a pass is made
    # with no changes to the grammar. For each winner:
    # * Error test the winner: see if it is the sole optimum for the
    #   mismatched input (all unset features assigned opposite their
    #   surface values) using the Faith-Low hierarchy. If it is, don't bother
    #   processing it (there is no learning error).
    # * If a learning error is detected, process the winner for new information.
    # 
    # A boolean is returned indicating if the grammar was changed at all
    # during the execution of this method.
    def run_single_form_learning
      begin
        grammar_changed_on_pass = false
        winner_list.each do |winner|
          # Error test the winner by checking to see if it is the sole
          # optimum for the mismatched input using the Faith-Low hierarchy.
          error_test = @error_test_class.new([winner], grammar)
          # Unless no error is detected, try learning with the winner.
          unless error_test.all_correct? then
            grammar_changed_on_winner = process_winner(winner)
            grammar_changed_on_pass = true if grammar_changed_on_winner
          end
        end
        @changed = true if grammar_changed_on_pass
      end while grammar_changed_on_pass
      return changed?
    end
    protected :run_single_form_learning

    # Processes +winner+ for new information about the grammar.
    # * First, it checks the winner for ranking information with a matched
    #   input, to see if any information was missed by phonotactic learning
    #   but is visible now.
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
    def process_winner(winner)
      change_on_winner = false
      # Check the winner to see if it is the sole optimum for
      # the matched input; if not, more ranking info is gained.
      # NOTE: several languages aren't learned if this step isn't taken.
      # TODO: investigate residual ranking info learning further
      new_ranking_info = @otlearn_module.ranking_learning_faith_low([winner], grammar)
      change_on_winner = true if new_ranking_info
      # Check the mismatched input for consistency. Only attempt to set
      # features in the winner if the mismatched winner is inconsistent.
      consistency_result = @otlearn_module.mismatch_consistency_check(grammar, [winner])
      unless consistency_result.grammar.consistent?
        # Attempt to set each unset feature of winner,
        # returning a list of newly set features
        set_feature_list = @otlearn_module.set_uf_values([winner], grammar)
        # For each newly set feature, check words unfaithfully mapping that
        # feature for new ranking information.
        set_feature_list.each do |set_f|
          @otlearn_module.new_rank_info_from_feature(grammar, winner_list, set_f)
        end
        change_on_winner = true unless set_feature_list.empty?
      end
      return change_on_winner
    end
    protected :process_winner
    
  end # class SingleFormLearning
end # module OTLearn

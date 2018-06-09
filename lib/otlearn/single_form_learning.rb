# Author: Bruce Tesar
#

require_relative "./grammar_test"
require_relative "./data_manip"

module OTLearn
  
  # When run, this processes all of the words in +winner_list+, one at a time
  # in order, with respect to +grammar+. Any results of learning are realized
  # as side effect changes to +grammar+.
  class SingleFormLearning
    
    # Creates the object. The learning procedure is not executed until
    # #run is called.
    # +winner_list+ is the list of all grammatical words.
    # +grammar+ is the grammar that learning will modify.
    def initialize(winner_list, grammar)
      @winner_list = winner_list
      @grammar = grammar
      @changed = false
      # injection dependency defaults
      @tester_class = OTLearn::GrammarTest
      @otlearn_module = OTLearn
    end
    
    # Resets the tester class used to determine which words require
    # more learning/information.
    # Used in testing (dependency injection).
    def tester_class=(test_obj)
      @tester_class = test_obj
    end
    
    # Resets the module providing the namespace for various learning methods.
    # Used in testing (dependency injection).
    def otlearn_module=(mod)
      @otlearn_module = mod
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
    def run
      begin
        grammar_changed_on_pass = false
        winner_list.each do |winner|
          # Error test the winner by checking to see if it is the sole
          # optimum for the mismatched input using the Faith-Low hierarchy.
          error_test = @tester_class.new([winner], grammar)
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
    def process_winner(winner)
      change_on_winner = false
      # Check the winner to see if it is the sole optimum for
      # the matched input; if not, more ranking info is gained.
      # NOTE: several languages aren' learned if this step isn't taken.
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

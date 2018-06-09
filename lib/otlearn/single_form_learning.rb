# Author: Bruce Tesar
#

require_relative "./grammar_test"
require_relative "./data_manip"

module OTLearn
  
  # When run, this processes all of the words in +winners+, one at a time in
  # order, with respect to +grammar+. Any results of learning are realized
  # as side effect changes to +grammar+.
  class SingleFormLearning
    
    # Creates the object. The learning procedure is not executed until
    # #run is called.
    # +winners+ is the list of all grammatical words.
    # +grammar+ is the grammar that learning will modify.
    def initialize(winners, grammar)
      @winners = winners
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
    def winners
      @winners
    end
    
    # The grammar resulting from this run of single form learning.
    def grammar
      @grammar
    end

    # Returns true if single form learning changed the grammar; false otherwise.
    def changed?
      return @changed
    end
    
    # Each winner is processed as follows:
    # * Error test the winner: see if it is the sole optimum for the
    #   mismatched input (all unset features assigned opposite their
    #   surface values) using the Faith-Low hierarchy.
    # * Check if the winner is optimal when unset input features are matched
    #   to the output, and if not, find more ranking info.
    # * Attempt to set any unset underlying features of the winner.
    # * For each newly set feature, check for new ranking information.
    # It passes repeatedly through the list of winners until a pass is made
    # with no changes to the grammar.
    # A boolean is returned indicating if the grammar was changed at all
    # during the execution of this method.
    def run
      begin
        grammar_changed_on_pass = false
        winners.each do |winner|
          # Error test the winner by checking to see if it is the sole
          # optimum for the mismatched input using the Faith-Low hierarchy.
          error_test = @tester_class.new([winner], grammar)
          # Unless no error is detected, try learning with the winner.
          unless error_test.all_correct? then
            # Check the winner to see if it is the sole optimum for
            # the matched input; if not, more ranking info is gained.
            # NOTE: several languages aren' learned if this step isn't taken.
            # TODO: investigate residual ranking info learning further
            new_ranking_info = @otlearn_module.ranking_learning_faith_low([winner], grammar)
            grammar_changed_on_pass = true if new_ranking_info
            # Check the mismatched input for consistency.
            # Unless the mismatched winner is consistent, attempt to set
            # each unset feature of the winner.
            consistency_result = @otlearn_module.mismatch_consistency_check(grammar, [winner])
            unless consistency_result.grammar.consistent?
              set_feature_list = @otlearn_module.set_uf_values([winner], grammar)
              grammar_changed_on_pass = true unless set_feature_list.empty?
              # For each newly set feature, check words unfaithfully mapping that
              # feature for new ranking information.
              set_feature_list.each do |set_f|
                @otlearn_module.new_rank_info_from_feature(grammar, winners, set_f)
              end
            end
          end
        end
        @changed = true if grammar_changed_on_pass
      end while grammar_changed_on_pass
      return changed?
    end
    
  end # class SingleFormLearning
end # module OTLearn

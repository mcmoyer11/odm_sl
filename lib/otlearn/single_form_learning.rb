# Author: Bruce Tesar
#

require_relative "./grammar_test"

module OTLearn
  class SingleFormLearning
    def initialize(winners, grammar)
      @winners = winners
      @grammar = grammar
      @changed = false
      # injection dependency defaults
      @tester_class = OTLearn::GrammarTest
      @language_learning = nil
      @otlearn_module = OTLearn
    end
    
    def tester_class=(test_obj)
      @tester_class = test_obj
    end
    
    def language_learning=(lang_learn)
      @language_learning = lang_learn
    end
    
    def otlearn_module=(mod)
      @otlearn_module = mod
    end
    
    def winners
      @winners
    end
    
    def grammar
      @grammar
    end
    
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
            consistency_result = @language_learning.mismatch_consistency_check(grammar, [winner])
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
    end
    
    def changed?
      return @changed
    end
    
  end # class SingleFormLearning

end # module OTLearn

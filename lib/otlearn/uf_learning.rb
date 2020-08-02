# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/input_feature_assigner'
require 'otlearn/conflict_feature_evaluator'

module OTLearn
  # Tests all possible values of the given underlying feature for
  # consistency with respect to the given word list, using the given
  # grammar. Conflict_features is a list of unset features which conflict
  # in their output realizations in the word list; all combinations of
  # values of them must be considered as local lexica when evaluating
  # a given feature value for consistency.
  # NOTE: the words of _word_list_ may exhibit side effects in their
  # input feature values.
  def OTLearn.consistent_feature_values(f_uf_inst, word_list,
                                        conflict_features, grammar)
    assigner = InputFeatureAssigner.new
    evaluator = OTLearn::ConflictFeatureEvaluator.new
    # Test every value of the target feature; store the consistent values
    consistent_values = []
    f_uf_inst.feature.each_value do |test_val|
      # Assign the current loop feature value to the input features
      assigner.assign_input_features(f_uf_inst, test_val, word_list)
      # see if a combination of conflict features consistent with test_val
      # exists
      consistent_combination_exists =
        evaluator.run(conflict_features, word_list, grammar)
      consistent_values << test_val if consistent_combination_exists
    end
    consistent_values
  end
end

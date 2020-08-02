# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/input_feature_assigner'
require 'otlearn/conflict_feature_evaluator'

module OTLearn
  # A consistent value finder evaluates a target underlying feature instance
  # with respect to a set of words and a grammar. It finds those values of
  # the target feature that result in consistency between the words and
  # the grammar, and returns those feature values.
  class ConsistentValueFinder
    # The conflict feature evaluator.
    # Default value: OTLearn::ConflictFeatureEvaluator.new
    attr_accessor :conflict_evaluator

    # Returns a new consistent value finder.
    # :call-seq:
    #   OTLearn::ConsistentValueFinder.new -> finder
    #--
    # input_assigner is a dependency injection used for testing.
    def initialize(input_assigner: InputFeatureAssigner.new)
      @assigner = input_assigner
      @conflict_evaluator = ConflictFeatureEvaluator.new
    end

    # Returns an array of the possible values of feature instance
    # _uf_finst_ that result in the words of the word_list being
    # consistent with the grammar for at least one combination of
    # values for the conflict_features.
    # Returns an empty array if none of the values of uf_finst
    # are consistent.
    # NOTE: the words of _word_list_ may exhibit side effects in
    # their input feature values, that is, the values of the input
    # features are changed during testing, and some may be different
    # from what they were prior to calling this method.
    def run(uf_finst, word_list, conflict_features, grammar)
      consistent_values = []
      # Test each value of the target feature.
      uf_finst.feature.each_value do |val|
        # Assign the tested value in the inputs of the words
        @assigner.assign_input_features(uf_finst, val, word_list)
        # See if a consistent combination of conflict features exists
        consistent_comb_exists =
          @conflict_evaluator.run(conflict_features, word_list, grammar)
        consistent_values << val if consistent_comb_exists
      end
      consistent_values
    end
  end
end

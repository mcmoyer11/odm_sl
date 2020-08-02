# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/consistency_checker'
require 'otlearn/input_feature_assigner'
require 'feature_value_combiner'

module OTLearn
  # Evaluates a set of words for consistency, with respect to different
  # combinations of feature values for conflict features.
  # A conflict feature is an unset feature that has different surface
  # values for different words within the evaluated set (the contrast set).
  class ConflictFeatureEvaluator
    # Checks the consistency of a set of candidates with a grammar.
    # Default value: ConsistencyChecker.new
    attr_accessor :consistency_checker

    # Returns a new conflict feature evaluator.
    # :call-seq:
    #   OTLearn::ConflictFeatureEvaluator.new -> evaluator
    #--
    # input_assigner and feature_combiner are dependency injections
    # used for testing.
    def initialize(input_assigner: InputFeatureAssigner.new,
                   feature_combiner: FeatureValueCombiner.new)
      @consistency_checker = ConsistencyChecker.new
      @assigner = input_assigner
      @combiner = feature_combiner
    end

    # Returns true if there is a combination of assigned values for the
    # conflict features that results in all of the members of the contrast
    # set being simultaneously consistent with the grammar.
    # Returns false otherwise.
    # It returns true for the first consistent combination of conflict
    # feature values encountered (it doesn't continue searching for others).
    def run(conflict_features, contrast_set, grammar)
      # Generate all combinations of values for the conflict features
      conflict_comb = @combiner.feature_value_combinations(conflict_features)
      # Test each combination, returning _true_ on the first consistent one.
      conflict_comb.each do |feat_comb|
        # assign the combination values to the inputs of the contrast set.
        feat_comb.each do |feat_pair|
          @assigner.assign_input_features(feat_pair.feature_instance,
                                          feat_pair.alt_value,
                                          contrast_set)
        end
        return true if @consistency_checker.consistent?(contrast_set,
                                                        grammar)
      end
      # Return _false_ if none of the conflict feature combinations
      # is consistent.
      false
    end
  end
end

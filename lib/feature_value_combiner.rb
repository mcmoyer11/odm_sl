# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature_value_pair'

# Objects of this class contain methods for enumerating and combining
# the values of feature instances in various ways.
class FeatureValueCombiner
  # Returns a new feature value combiner.
  # :call_seq:
  #   FeatureValueCombiner.new -> combiner
  #--
  # fvp_class is a dependency injection used for testing.
  def initialize(fvp_class: FeatureValuePair)
    @fvp_class = fvp_class
  end

  # Takes a list of feature instances, and returns an array of entries,
  # one entry for each feature instance, where each entry is an array
  # of feature value pairs, one for each possible value of that feature.
  def values_by_feature(feat_inst_list)
    feat_inst_list.each_with_object([]) do |feat_inst, feat_values_list|
      fv_pairs = []
      feat_inst.feature.each_value do |alt_value|
        fv_pairs << @fvp_class.new(feat_inst, alt_value)
      end
      feat_values_list << fv_pairs
    end
  end

  # Takes a list of feature instances, and returns an array of
  # combinations of feature values, where each combination is an array
  # of feature value pairs, one for a possible value of each of the
  # features.
  # If the provided list of feature instances is empty, then an array
  # containing a single empty array is returned, representing the
  # single possible combination of values of zero features: [[]].
  def feature_value_combinations(feat_inst_list)
    values = values_by_feature(feat_inst_list)
    if values.empty?
      [[]]
    else
      # Compute the cartesian product of the lists of possible values
      # of the features.
      values[0].product(*values[1..-1])
    end
  end
end

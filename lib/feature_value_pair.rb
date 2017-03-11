# Author: Bruce Tesar
# 

# A FeatureValuePair is a specific feature instance, paired with
# a *possible* value for the feature, called the _alt_value_.
# The point is to be able to
# store and reason with possible values for particular feature instances
# without having to actually set the given feature instance to that value.
# This is useful for representing things like possible combinations of
# values for features; a particular combination can be represented as
# a list of Feature Value Pairs, allowing one to simultaneously represent
# multiple such combinations. At any desired time, a feature instance
# can be set to the associated alt_value with #set_to_alt_value.
class FeatureValuePair
  # Returns a FeatureValuePair with feature instance _feature_instance_ and
  # alt_value _value_.
  def initialize(feature_instance, value)
    # Verify that _value_ is a possible value of _feature_instance_.
    fvs=[]; feature_instance.feature.each_value{|val| fvs<<val}
    unless fvs.member?(value)
      raise "Feature value #{value} is not a possible value for #{feature_instance.feature.type}"
    end
    @feature_instance = feature_instance
    @alt_value = value
  end

  # This class method accepts a list of feature instances _feature_list_
  # and returns an array of lists, one list for each feature of _feature_list_.
  # The list for each feature is a list of FeatureValuePairs, all having
  # the given feature instance, with one pair for each possible value of
  # the feature.
  def FeatureValuePair.all_values_pairs(feature_list)
    feat_values_list = []
    feature_list.each do |feat_inst|
      feat_values = []
      feat_inst.feature.each_value do |alt_value|
        feat_values << FeatureValuePair.new(feat_inst, alt_value)
      end
      feat_values_list << feat_values
    end
    return feat_values_list
  end

  # Returns the feature instance of this Feature Value Pair.
  def feature_instance
    @feature_instance
  end

  # Returns the alt_value of this Feature Value Pair.
  def alt_value
    @alt_value
  end

  # Sets the value of the feature instance of this pair to the alt_value
  # of this pair.
  def set_to_alt_value
    @feature_instance.feature.value = @alt_value
  end

  # Make it easy to read what the features are that are causing learning to fail
  def to_s
    "Feature #{@feature_instance} with hypothesized value #{@alt_value} is consistent."
  end
  
end

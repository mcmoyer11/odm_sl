# frozen_string_literal: true

# Author: Morgan Moyer

# TODO: this should be contained in the module OTLearn.

# This class of exceptions holds the +feature_value_list+
# for languages which fail learning.
class LearnEx < RuntimeError
  # List of consistent features that Fewest Set Features
  # cannot choose between.
  attr_reader :consistent_feature_value_list

  # Returns a new LearnEx exception object.
  def initialize(consistent_feature_value_list)
    @consistent_feature_value_list = consistent_feature_value_list
  end
end

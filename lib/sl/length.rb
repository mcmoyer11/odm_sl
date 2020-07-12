# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature'

module SL
  # A length feature has type LENGTH. The two feature values are
  # represented by the constants SHORT and LONG.
  # The class mixes in Feature, providing most of the functionality.
  class Length
    include Feature

    # Feature type vowel length
    LENGTH = :length

    # Feature value short vowel
    SHORT = :short

    # Feature value long vowel
    LONG = :long

    # Declare SHORT a feature value.
    # Provides methods #short? and #set_short.
    feature_value SHORT

    # Declare LONG a feature value.
    # Provides methods #long? and #set_long.
    feature_value LONG

    # Returns a new length feature, with the feature value unset.
    def initialize
      @type = LENGTH
      @value = UNSET
      @value_list = [SHORT, LONG].freeze
    end

    # Returns a string representation of the feature:
    # "length=<value>"
    def to_s
      return 'length=long' if long?
      return 'length=short' if short?

      'length=unset'
    end
  end
end

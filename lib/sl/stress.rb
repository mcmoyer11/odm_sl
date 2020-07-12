# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature'

module SL
  # A stress feature has type STRESS. The two feature values are
  # represented by the constants UNSTRESSED and MAIN_STRESS.
  # The class mixes in Feature, providing most of the functionality.
  class Stress
    include Feature

    # Feature type stress
    STRESS = :stress

    # Feature value unstressed syllable
    UNSTRESSED = :unstressed

    # Feature value main stress syllable
    MAIN_STRESS = :main_stress

    # Declare UNSTRESSED a feature value.
    # Provides methods #unstressed? and #set_unstressed.
    feature_value UNSTRESSED

    # Declare MAIN_STRESS a feature value.
    # Provides methods #main_stress? and #set_main_stress.
    feature_value MAIN_STRESS

    # Returns a new stress feature, with the feature value unset.
    def initialize
      @type = STRESS
      @value = UNSET
      @value_list = [UNSTRESSED, MAIN_STRESS].freeze
    end

    # Returns a string representation of the feature:
    # "stress=<value>"
    def to_s
      return 'stress=unstressed' if unstressed?
      return 'stress=main_stress' if main_stress?

      'stress=unset'
    end
  end
end

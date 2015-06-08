# Author: Crystal Akers, based on Bruce Tesar's sl/stress_feat
#

require_relative '../feature'

module SF

  # A stress feature is a Feature of type STRESS.
  # It has three possible feature values, represented
  # by the constants UNSTRESSED, MAIN_STRESS, and SEC_STRESS
  class Stress_feat < Feature
    #-- Symbols are used as lightweight, readable constants ++

    # Feature type stress
    STRESS = :stress
    # Feature value unstressed syllable
    UNSTRESSED = :unstressed
    # Feature value main stress syllable
    MAIN_STRESS = :main_stress

    # Returns a new stress feature, with the feature value unset.
    def initialize
      super(STRESS) # Pass the feature type to Feature#initialize.
    end

    # Returns true if the feature instance is unstressed; false otherwise.
    def unstressed?
      self.value == UNSTRESSED
    end

    # Returns true if the feature instance is main_stress; false otherwise.
    def main_stress?
      self.value == MAIN_STRESS
    end

    # Returns true if the feature instance is main_stress or sec_stress;
    # false otherwise.
    def stressed?
      self.value == MAIN_STRESS
    end

    # Sets the feature to the value UNSTRESSED.
    def set_unstressed
      self.value = UNSTRESSED
      self
    end

    # Sets the feature to the value MAIN_STRESS.
    def set_main_stress
      self.value = MAIN_STRESS
      self
    end

    # Returns a string representation of the feature:
    # "stress=<value>"
    def to_s
      return "stress=unset" if unset?
      return "stress=unstressed" if unstressed?
      return "stress=main_stress" if main_stress?
      return "stress=sec_stress" if sec_stress?
    end

    #-- Generic interface ++

    # Passes each possible value for this feature to the given code block,
    # one at a time (iterator style). This generic interface should be
    # used by all feature types.
    def each_value
      yield UNSTRESSED
      yield MAIN_STRESS
    end

  end # class Stress_feat

end # module SF
# frozen_string_literal: true

# Author: Bruce Tesar

# Represents a specific feature instance: a feature of a particular type
# associated with a specific feature-bearing element (one that can stand
# in a correspondence relation). A FeatureInstance is itself neither a
# feature nor a feature-bearing element: it contains a reference to each.
#
# This is useful for things like lists of unset features: each instance
# indicates a particular feature of a particular feature-bearing element.
#
# A FeatureInstance is designed to be immutable: references to the
# feature-bearing element and the feature are passed to the constructor,
# and no other methods are available to later modify the feature instance.
# *However*, it is possible to change the value of the referenced feature.
# Convenience methods are provided to accessing and modifying the value
# of the feature: #value and #value=.
class FeatureInstance
  # The feature-bearing element (e.g., a segment)
  attr_reader :element

  # A particular feature of the feature-bearing element.
  attr_reader :feature

  # Creates a new feature instance, referencing _element_ and its
  # _feature_.
  # :call-seq:
  #   FeatureInstance.new(element, feature) -> instance
  def initialize(element, feature)
    # Make sure that the parameter feature is actually a feature of the
    # parameter feature-bearing element.
    unless feature.equal?(element.get_feature(feature.type))
      raise 'The feature must belong to the element'
    end

    @element = element
    @feature = feature
  end

  # Returns the value of this feature.
  def value
    @feature.value
  end

  # Sets the value of this feature to _new_value_.
  def value=(new_value)
    @feature.value = new_value
  end

  # Returns the morpheme associated with the element containing
  # this feature.
  def morpheme
    @element.morpheme
  end

  # Returns a string representation of the feature instance.
  def to_s
    "#{@element.morpheme} #{@feature} #{@element}"
  end
end

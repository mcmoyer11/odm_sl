# Author: Bruce Tesar
#

# This is the base class for features; subclasses will provide the specific
# properties (like possible values) for specific feature types.
class Feature
  attr_accessor :value, :type

  # A feature type is set to _type_. The feature value is initialized
  # to unset (which is represented with nil).
  def initialize(type)
    @value = nil
    @type = type
  end

  # Distinct feature objects are equivalent if they have
  # equivalent type and value.
  def ==(other)
    (@type == other.type) && (@value == other.value)
  end
  
  # The same as ==(_other_).
  def eql?(other)
    self==other
  end

  # Returns true if a feature is unset; false otherwise.
  def unset?
    return @value.nil?
  end
  
end

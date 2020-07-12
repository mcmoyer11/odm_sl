# frozen_string_literal: true

# Author: Bruce Tesar

# A mixin for feature classes. The host class must initialize
# the attributes _type_, _value_, and _value_list_.
module Feature
  # The feature value for an unset feature.
  UNSET = nil

  # The feature type.
  attr_reader :type

  # A list of the possible feature values. Does NOT include unset.
  attr_reader :value_list

  # The value of the feature.
  attr_accessor :value

  # Inner module containing methods to be added as class methods.
  module ClassMethods
    def feature_value(name)
      define_method("#{name}?") { value == name }
      define_method("set_#{name}") do
        self.value = name
        self
      end
    end
  end

  # Hook method that is executed whenever this module is included into
  # a class (the host class). Here, it uses _extend_ to add the contents
  # of _ClassMethods_ as class methods to the host class.
  def self.included(host_class)
    host_class.extend(ClassMethods)
  end

  # Returns true if a feature is unset; false otherwise.
  def unset?
    value == UNSET
  end

  # Returns true if _val_ is a valid value for the feature;
  # returns false otherwise.
  def valid_value?(val)
    value_list.include?(val)
  end

  # An iterator for possible values of the feature. It yields the possible
  # values of the feature to the provided block.
  def each_value
    value_list.each { |val| yield val }
  end

  # Distinct feature objects are equivalent if they have
  # equivalent type and value.
  def ==(other)
    (type == other.type) && (value == other.value)
  end

  # The same as ==(_other_).
  def eql?(other)
    self == other
  end
end

# encoding: UTF-8
# 
# Author: Crystal Akers, based on Bruce Tesar's sl/syllable
#

require_relative 'syllable'

module SF

  # An output syllable for the SF system has one feature, stress. The stress feature
  # can have the value primary stress or unstressed. Secondary stress is assigned
  # with a T/F parameter. The combinations of stress feature and secondary stress
  # create the following output syllables:
  #   Primary stress and false for sec stress = primary stress syllable
  #   Unstressed and false for sec stress = unstressed syllable
  #   Unstressed and true for sec stress = secondary stress syllable
  #   (Primary stress and true for sec stress is not allowed)
  # Output syllable also can have an affiliated morpheme.

  class Output_Syllable < Syllable

    # Returns a syllable, initialized to the parameters if provided. Otherwise,
    # returns a syllable with unset features, an empty string for the
    # morpheme, and does not have secondary stress.
    def initialize(stress=Stress_feat.new,sec_stress =false, morph="" )
      @stress = stress
      @sec_stress = sec_stress
      @morpheme = morph # label of the morpheme this syllable is affiliated with
      if @stress.stressed? and @sec_stress==true then
        raise "Cannot have both primary and secondary stress"
      end
    end

    # A duplicate makes copies of the features, so that they may be altered
    # independently of the original's features.
    def dup
      self.class.new(@stress.dup, @sec_stress, @morpheme)
    end

    # Protected accessors, only used for #==()
    attr_reader :stress # :nodoc:
    protected :stress # :nodoc:

    # Returns true if this syllable matches _other_, a syllable, in the values
    # the stress feature, and morpheme identity.
    def ==(other)
      return false unless other.class == self.class
      return false unless @stress==other.stress
      return false unless @sec_stress == other.sec_stress?
      return false unless @morpheme==other.morpheme
      return true
    end

    # The same as ==(other).
    def eql?(other)
      self==other
    end

    # Returns true if the syllable's stress feature has the value
    # main_stress.
    def main_stress?
      @stress.main_stress?
    end

    # Returns true if the syllable's stress feature has the value
    # unstressed and  the sec_stress parameter is true.
    def sec_stress?
      !@stress.stressed? and @sec_stress == true
    end

    # TODO should this be changed to a head? method instead?
    # Returns true if the syllable's stress feature has the value
    # main_stress or the sec_stress is true.
    def stressed?
      @stress.stressed? or @sec_stress == true
    end

    # Returns true if the syllable's stress feature has the value
    # unstressed.
    def unstressed?
      @sec_stress == false and super
    end

    # Returns true is the stress feature is unset.
    def stress_unset?
      @stress.unset? and @sec_stress == false
    end

    # Returns the morpheme that this syllable is affiliated with.
    def morpheme
      @morpheme
    end

    # Sets the syllable's stress feature to the value main_stress.
    def set_main_stress
      @stress.set_main_stress
      self
    end

    # Sets the syllable's sec_stress parameter to true and the stress feature value
    # to unstressed.
    def set_sec_stress
      @stress.set_unstressed
      @sec_stress = true
      self
    end

    # Sets the syllable's stress feature to the value unstressed and sets
    # the sec_stress parameter to false.
    def set_unstressed
      @stress.set_unstressed
      @sec_stress = false
      self
    end

    # Set the morpheme that this syllable is affiliated with to _m_.
    def set_morpheme(m)
      @morpheme = m
      self
    end

    # Returns the number of syllables in this "word element".
    # A syllable always contains 1 syllable. This allows us to
    # easily add up the number of syllables in a word, without
    # having to worry about whether each element of the word is
    # an unfooted syllable or a foot: each element knows how
    # to answer the question "how many syllables do you have?"
    def syllable_count
      return 1
    end

    #Iterates over the single syllable.
    def each_syllable
      yield self
    end

    # Returns a string representation of the syllable, consisting of one
    # character, denoting the stress feature:
    #
    # unstressed:: [s]
    # main stress:: [Y]
    # sec_stress:: [X]
    # unset:: [?]
    def to_s
      stress_s = case
      when main_stress? then "Y"
      when sec_stress? then "X"
      when unstressed? then "s"
      when stress_unset? then "?"
      end
      return stress_s
    end

    def to_gv
      base = "morpheme_type_not_defined"
      if morpheme.root? then
        base = "p"
      elsif morpheme.suffix? then
        base = "k"
      elsif morpheme.prefix? then
        base = "t"
      end
      stress_s = case
      when main_stress? then "á"
      when sec_stress? then "à"
      when unstressed? then "a"
      when stress_unset? then "?"
      end
      return base + stress_s
    end

    # Iterator over the features of the syllable.
    # TODO should this method also return values for sec stress? Does
    # the method ever need to be used with output syllables?
    def each_feature()
      yield @stress
    end

    # Returns the syllable's _type_ feature. Raises an exception if the
    # syllable does not have a feature of type _type_.
    def get_feature(type)
      each_feature{|f| return f if f.type==type}
      raise "SF::Syllable#get_feature(): parameter #{type.to_s} is not a valid feature type."
    end

    # TODO: create a set_feature(feat_type,val) method

  end # class Output_Syllable

end # module SF


# encoding: UTF-8
# 
# Author: Crystal Akers, based on Bruce Tesar's sl/syllable
#

require_relative 'stress_feat'

module SF

  # A syllable for the SF system has one feature, stress. It also
  # can have an affiliated morpheme.
  #
  # Learning algorithms are expected to use the "generic" interface, consisting
  # of the methods #each_feature() and #get_feature(). The method #each_feature()
  # is an iterator that yields each feature of the syllable in turn,
  # allowing other routines to work with syllables without knowing in advance
  # how many or what types of features they have.
  class Syllable

    # Returns a syllable, initialized to the parameters if provided. Otherwise,
    # returns a syllable with unset features, and an empty string for the
    # morpheme.
    def initialize(stress=Stress_feat.new, morph="")
      @stress = stress
      @morpheme = morph # label of the morpheme this syllable is affiliated with.
    end

    # A duplicate makes copies of the features, so that they may be altered
    # independently of the original's features.
    def dup
      self.class.new(@stress.dup, @morpheme)
    end

    # Protected accessors, only used for #==()
    attr_reader :stress # :nodoc:
    protected :stress # :nodoc:

    # Returns true if this syllable matches _other_, a syllable, in the values
    # the stress feature, and morpheme identity.
    def ==(other)
      return false unless other.class == self.class
      return false unless @stress==other.stress
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
    # main_stress or sec_stress.
    def stressed?
      @stress.stressed?
    end

    # Returns true if the syllable's stress feature has the value
    # unstressed.
    def unstressed?
      @stress.unstressed?
    end

    # Returns true is the stress feature is unset.
    def stress_unset?
      @stress.unset?
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

    # Sets the syllable's stress feature to the value unstressed.
    def set_unstressed
      @stress.set_unstressed
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
    # unset:: [?]
    def to_s
      stress_s = case
      when main_stress? then "Y"
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
      when unstressed? then "a"
      when stress_unset? then "?"
      end
      return base + stress_s
    end

    # Iterator over the features of the syllable.
    def each_feature() # :yields: feature
      yield @stress
    end

    # Returns the syllable's _type_ feature. Raises an exception if the
    # syllable does not have a feature of type _type_.
    def get_feature(type)
      each_feature{|f| return f if f.type==type}
      raise "SF::Syllable#get_feature(): parameter #{type.to_s} is not a valid feature type."
    end

    # Sets the syllable's _feat_type_ to _value_.
    def set_feature(feat_type,val)
      f = get_feature(feat_type)
      f.value = val
    end

  end # class Syllable

end # module SF

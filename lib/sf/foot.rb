# Author: Crystal Akers, based on Bruce Tesar's Ruby_on_RORG foot.rb

require_relative 'syllable'

module SF

# A foot consists of one or two syllables.
class Foot
  
  # A complete foot must be created at once, with the
  # syllables being provided as arguments to #new().
  # The '*' operator in front of the parameter args
  # stores the parameters passed into the method in
  # an array, referenced by args. This allows the method
  # to accommodate a variable number of passed
  # parameters; in this case, one or two syllables.
  def initialize(*args)
    raise "No empty feet!" if args.empty?
    raise "No suprabinary feet!" if args.size > 2
    raise "One syllable must be stressed" if args.all? {|syl| syl.unstressed?}
    raise "Only one syllable may be stressed" if args.size == 2 and !args.any? {|syl| syl.unstressed?}
    @syllables = args
  end


  # Returns the number of syllables in the foot.
  def syllable_count
    return @syllables.size
  end

  # Returns the first syllable in the foot.
  def first_syl
    return @syllables[0]
  end

  # Returns the second syllable in the foot. Returns nil if the
  # foot only has one syllable.
  def second_syl
    return @syllables[1]
  end

  # Returns the last syllable in the foot, whether it is the first syllable
  # or the second.
  def last_syl
    if @syllables.size == 1
      return @syllables[0]
    else return @syllables[1]
    end
  end

  #Iterator over each syllable in a foot
  def each_syllable
    yield self.first_syl
    yield self.second_syl if @syllables.size == 2
  end

  # Returns true if the stress feature of any syllable in the foot has the value
  # main_stress.
  def main_stress?
    @syllables.any? { |syl| syl.main_stress?  }
  end

  # Returns true if this foot and _other_ foot have the same number of syllables and the
  # syllables themselves are equivalent.
  # TODO this method might need to change -- check notes.
  def ==(other)
    val = false
    if self.class == other.class then
      if self.syllable_count == other.syllable_count then
        val = true if self.first_syl == other.first_syl && self.second_syl == other.second_syl
      end
    end
    return val
  end

  # Equivalent to ==().
  def eql?(other)
    self==other
  end

  #  A duplicate makes copies of the syllables, so that their features may be altered
  #  independently of the original syllables' features.
    def dup
      if self.syllable_count == 2 then
        return Foot.new(self.first_syl.dup, self.second_syl.dup)
      else return Foot.new(self.first_syl.dup)
      end
    end

  # Represents a foot as a pair of parentheses containing
  # the to_s representation of each syllable in the foot,
  # without separators.
  def to_s
    outstr = "("
    @syllables.each {|syl| outstr += syl.to_s}
    return outstr += ")"
  end

end # class Foot

end # module SF
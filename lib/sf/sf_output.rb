# Author: Crystal Akers
#

require_relative '../output'
require_relative 'foot'
require_relative 'output_syllable'

module SF

  # Contains

  class SF::Sf_output < Output

    # A newly created output is empty, with no morphological word, so that
    # it can be built up piece by piece.
    def initialize
      @morphword = nil
    end
  
    # Returns the number of syllables in the output, by adding up the number of
    # syllables in each element of the word.
    def syllable_count
      return inject(0){|total,element| total + element.syllable_count}
    end

    # Iterator over the elements of the output (unparsed syllables or feet)
    def each_element()
      self.each { |el| yield el }
    end

    #Iterator over each syllable in an output element (unparsed syllable or foot)
    def each_syllable()
      self.each do |el|
        el.each_syllable { |syl| yield syl }
      end
    end

    # Creates an array containing each syllable in the output in order.
    def syl_list
      list = Sf_output.new
      self.each_syllable { |syl| list << syl }
      return list
    end

  # Returns a copy of the output as an overt form, containing a duplicate of each
  # syllable and a duplicate of the morphological word.
  def overt
    overt_copy = Sf_output.new
    self.each_syllable {|syl| overt_copy << syl }
    overt_copy.morphword = @morphword.dup unless @morphword.nil?
    return overt_copy
  end

  # Returns a copy of the output, containing a duplicate of each
  # correspondence element and a duplicate of the morphological word.
  def dup
    # Call Array#map to get an array of dups of the elements, and add
    # them to a new Output.
    copy = Sf_output.new.concat(super.map { |el| el.dup })
    copy.morphword = @morphword.dup unless @morphword.nil?
    return copy
  end

  end # class SF::Sf_output

end # module SF
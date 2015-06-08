# Author: Crystal Akers
#

require 'REXML/syncenumerator'
require_relative '../input'
require_relative '../output'
require_relative '../io_correspondence'
require_relative '../word'
require_relative 'sf_output'
require_relative '../rubot'
require 'candidate'

module SF

  # Contains
  
  # An Sf_word is a Word with an Sf_output.
  
  class SF::Sf_word < Word

    # A word starts out with an empty input and sf_output by default, but
    # input and output can be optionally passed as parameters.
    # The linguistic system is a mandatory parameter, and
    # the correspondence relation is initially empty;
    # correspondences must be added after the word is created.
    def initialize(system, input=Input.new, output=Sf_output.new)
      super(system, input, output)
    end

    # Returns a deep copy of the word, with distinct input syllables and features,
    # distinct output elements and features, and appropriately revises UI and
    # IO correspondences.
    def dup
      copy = Sf_word.new(@system)
      copy.label = self.label
      copy.opt=self.opt?
      # Make local references to reduce number of method calls
      c_input = copy.input
      c_output = copy.output
      c_io_corr = copy.io_corr
      # dup the morphological word for the copy's input and output
      unless input.morphword.nil?
        c_morphword = input.morphword.dup
        c_input.morphword = c_morphword
        c_output.morphword = c_morphword
      end
      # Make a copy of the input, constructing updated versions of the UI
      # and IO correspondences using the new copies of the input syllables.
      input.each do |old_in_syl|
        new_in_syl = old_in_syl.dup # duplicate the old input syllable
        c_input << new_in_syl # add the dup to the copy
        # get the corresponding underlying syllable in the original's UI correspondence.
        # If it exists, add a correspondence to the copy between this underlying
        # syllable and the duplicated input syllable in the copy.
        under_syl = input.ui_corr.under_corr(old_in_syl)
        c_input.ui_corr << [under_syl,new_in_syl] unless under_syl.nil?
        # get the corresponding output syllable in the original word's IO corresp.
        out_syl = @io_corr.out_corr(old_in_syl)
        c_io_corr << [new_in_syl,out_syl] unless out_syl.nil?
      end
      # Make a copy of the output, adjusting the O part of IO correspondence.
      output.each do |old_out_el|
        new_out_el = old_out_el.dup # duplicate the old output element (foot or unparsed syllable)
        c_output << new_out_el # add the dup to the copy
        # find the IO pair.
        new_out = []; old_out = []
        new_out_el.each_syllable {|syl| new_out << syl}
        old_out_el.each_syllable {|syl| old_out << syl}
        gen = REXML::SyncEnumerator.new(new_out,old_out)
        gen.each do |new_out_syl,old_out_syl|
          corr_pair = c_io_corr.find{|p| p[1].equal?(old_out_syl)}
          corr_pair[1] = new_out_syl unless corr_pair.nil? # replace old with new output syl.
        end
      end
      copy.eval # set the constraint violations
      return copy
    end

    # Returns the overt form of the word.
    def overt()
      return self.output.overt
    end

  end # class Sf_word
    
end # module SF
# Author: Bruce Tesar
#
 
require 'singleton'
require 'REXML/syncenumerator'
require_relative '../constraint'
require_relative '../ui_correspondence'
require_relative '../word'
require_relative '../competition'
require_relative '../input_factory'

module SL

  # Contains the core elements of the SL (stress-length) linguistic system.
  # It defines the constraints of the system, provides the #gen(_input_) method
  # generating the candidates for _input_, provides a method for
  # constructing the phonological input corresponding to a morphological
  # word with respect to a given grammar, and provides a method for parsing
  # a phonological output for a morphological word into a full structural
  # description with respect to a given grammar.
  #
  # This is a singleton class.
  class System
    include Singleton

    # Create local references to the constraint type constants.
    # This is strictly for convenience, so that the "Constraint::"
    # prefix doesn't have to appear in the constraint definitions below.
    # Note: done this way because constants cannot be aliased.

    # Indicates that a constraint is a markedness constraint.
    MARK = Constraint::MARK
    # Indicates that a constraint is a faithfulness constraint.
    FAITH = Constraint::FAITH

    # Creates the constraints and the constraint list.
    # Freezes the constraints and the constraint list.
    def initialize
      initialize_constraints
      @constraints = constraint_list # private method creating the list
      @constraints.each {|con| con.freeze} # freeze the constraints
      @constraints.freeze # freeze the constraint list
    end

    # Sets the input factory object for creating new input objects.
    # *NOTE*: must be called before using the System instance.
    # This dependence is set in this way due to the fact that System
    # is a Singleton class.
    # The call sequence should be something like:
    # *  system = SL::System.instance
    # *  system.set_input_factory(Input_factory.new)
    def set_input_factory(factory)
      @input_factory = factory
    end

    # Returns the list of constraints (each constraint is a Constraint object).
    # Note that the returned list is frozen, as are the constraints that
    # it contains.
    def constraints() return @constraints end

    # Returns the markedness constraint NoLong.
    def nolong() return @nolong end
    # Returns the markedness constraint WSP.
    def wsp() return @wsp end
    # Returns the markedness constraint ML.
    def ml() return @ml end
    # Returns the markedness constraint MR.
    def mr() return @mr end
    # Returns the faithfulness constraint IDStress.
    def idstress() return @idstress end
    # Returns the faithfulness constraint IDLength.
    def idlength() return @idlength end

    # Accepts parameters of a morph_word and a grammar. It builds an input form
    # by concatenating the syllables of the underlying forms of each of the
    # morphemes in the morph_word, in order. It also constructs the correspondence
    # relation for the input, with an entry for each corresponding pair of
    # underlying/input syllables.
    def input_from_morphword(mw, gram)
      input = @input_factory.new_input
      input.morphword = mw
      mw.each do |m| # for each morpheme in the morph_word, in order
        uf = gram.get_uf(m)
        raise "Morpheme #{m.label} has no entry in the lexicon." if uf.nil?
        uf.each do |syl| # for each syllable of the underlying form
          in_syl = syl.dup
          input.push(in_syl) # add a duplicate of the underlying syllable to input.
          input.ui_corr << [syl,in_syl] # create a correspondence between underlying and input syllables.
        end
      end
      return input
    end

    # gen takes an input, generates all candidate words for that input, and returns
    # them in the form of a Competition. All candidates are marked
    # as not optimal.
    # All candidates in the competition share the same input object. The outputs
    # for candidates may also share some of their syllable objects.
    def gen(input)
      start_rep = Word.new(SYSTEM,input) # full input, but empty output, io_corr
      start_rep.output.morphword = input.morphword
      # create two lists of partial candidates, distinguished by whether or
      # not they contain a syllable with main stress.
      no_stress_yet = [start_rep]
      main_stress_assigned = []

      # for each input segment, add it to the output in all possible ways,
      # creating new partial candidates
      input.each do |isyl|
        # copy the partial candidate lists to old_*, and reset the lists to empty.
        old_no_stress_yet = no_stress_yet
        old_main_stress_assigned = main_stress_assigned
        no_stress_yet = []; main_stress_assigned = []
        # iterate over old_no_stress_yet, for each member create a new candidate
        # for each of the ways of adding the next syllable.
        old_no_stress_yet.each do |w|
          no_stress_yet << extend_word_output(w, isyl){|s| s.set_unstressed.set_short}
          main_stress_assigned << extend_word_output(w, isyl){|s| s.set_main_stress.set_short}
          no_stress_yet << extend_word_output(w, isyl){|s| s.set_unstressed.set_long}
          main_stress_assigned << extend_word_output(w, isyl){|s| s.set_main_stress.set_long}
        end
        # iterate over old_main_stress_assigned, for each member create
        # a new candidate for each of the ways of adding the next syllable.
        old_main_stress_assigned.each do |w|
          main_stress_assigned << extend_word_output(w, isyl){|s| s.set_unstressed.set_short}
          main_stress_assigned << extend_word_output(w, isyl){|s| s.set_unstressed.set_long}
        end
      end

      # Put actual candidates into competition, calling eval on each to set
      # the constraint violations.
      competition = Competition.new
      main_stress_assigned.each{|c| c.eval; competition.push(c)}
      return competition
    end

    # Constructs a full structural description for the given output using the
    # lexicon of the given grammar. The constructed input will stand in
    # 1-to-1 IO correspondence with the output; an exception is thrown if
    # the number of syllables in the lexical entry of each morpheme doesn't
    # match the number of syllables for that morpheme in the output.
    def parse_output(output, gram)
      mw = output.morphword
      # If any morphemes aren't currently in the lexicon, create new entries, with
      # the same number of syllables as in the output, and all features unset.
      mw.each do |m|
        unless gram.lexicon.any?{|entry| entry.morpheme==m} then
          under = Underlying.new
          # create a new UF syllable for each syllable of m in the output
          syls_of_m = output.find_all{|syl| syl.morpheme==m}
          syls_of_m.each { |x| under << SL::Syllable.new.set_morpheme(m) }
          gram.lexicon << Lexical_Entry.new(m,under)
        end
      end
      # Construct the input form
      input = input_from_morphword(mw, gram)
      word = Word.new(SYSTEM,input,output)
      # create 1-to-1 IO correspondence
      if input.size != output.size then
        raise "Input size #{input.size} not equal to output size #{output.size}."
      end
      gen = REXML::SyncEnumerator.new(input, output)
      gen.each do |in_syl,out_syl|
        word.io_corr << [in_syl,out_syl]
        if in_syl.morpheme != out_syl.morpheme then
          raise "Input syllable morph #{in_syl.morpheme.label} != " +
            "output syllable morph #{out_syl.morpheme.label}"
        end
      end
      word.eval
      return word
    end

    private
    def initialize_constraints
      @nolong = Constraint.new("NoLong", 1, MARK) do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? then sum+1 else sum end
        end
      end
      @wsp = Constraint.new("WSP", 2, MARK) do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? && syl.unstressed? then sum+1 else sum end
        end
      end
      @ml = Constraint.new("ML", 3, MARK) do |cand|
        viol_count = 0
        for syl in cand.output do
          break if syl.main_stress?
          viol_count += 1
        end
        viol_count
      end
      @mr = Constraint.new("MR", 4, MARK) do |cand|
        viol_count = 0
        stress_found = false
        for syl in cand.output do
          viol_count += 1 if stress_found
          stress_found = true if syl.main_stress?
        end
        viol_count
      end
      @idstress = Constraint.new("IDStress", 5, FAITH) do |cand|
        cand.io_corr.inject(0) do |sum, pair|
          if pair[0].stress_unset? then sum
          elsif pair[0].main_stress?!=pair[1].main_stress? then sum+1
          else sum
          end
        end
      end
      @idlength = Constraint.new("IDLength", 6, FAITH) do |cand|
        cand.io_corr.inject(0) do |sum, pair|
          if pair[0].length_unset? then sum
          elsif pair[0].long?!=pair[1].long? then sum+1
          else sum
          end
        end
      end      
    end
    
    # Define the constraint list.
    def constraint_list
      list = []
      list << @nolong
      list << @wsp
      list << @ml
      list << @mr
      list << @idstress
      list << @idlength
      return list
    end

    # Takes a word partial description (full input, partial output), along with
    # a reference to the next input syllable to have a correspondent added
    # to the output. A copy of the word, containing the new output syllable
    # as an output correspondent to the input syllable, is returned.
    #
    # The new output syllable is formed by duplicating
    # the input syllable (to copy morpheme info, etc.), and then the output
    # syllable is passed to the block parameter, which sets the feature values
    # for the new output syllable. The new output syllable is added to the end
    # of the output, and a new IO correspondence pair is added.
    def extend_word_output(word, in_syl)
      new_w = word.dup_for_gen
      out_syl = yield(in_syl.dup) # block sets features of new output syllable.
      new_w.output << out_syl
      new_w.io_corr << [in_syl,out_syl]
      return new_w
    end

  end # class SL::System

  # The system object for the linguistic system SL (stress-length).
  SYSTEM = System.instance

end # module SL
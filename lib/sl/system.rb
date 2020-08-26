# frozen_string_literal: true

# Author: Bruce Tesar

require 'singleton'
require 'sl/syllable'
require 'constraint'
require 'input'
require 'ui_correspondence'
require 'word'
require 'underlying'
require 'lexical_entry'

# Module SL contains the linguistic system elements defining the
# Stress-Length (SL) linguistic system. SL builds words from syllables,
# where each syllable has two vocalic features: stress and (vowel) length.
# Each output must have exactly one stress-bearing syllable.
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
  #
  # ===Non-injected Class Dependencies
  # * SL::Syllable
  # * Constraint
  # * Input
  # * UICorrespondence
  # * Word
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

    # Creates and freezes the constraints and the constraint list.
    def initialize
      initialize_constraints
      @constraints = constraint_list # private method creating the list
      @constraints.each(&:freeze) # freeze the constraints
      @constraints.freeze # freeze the constraint list
    end

    # Returns the list of constraints (each constraint is a Constraint object).
    # Note that the returned list is frozen, as are the constraints that
    # it contains.
    def constraints
      @constraints
    end

    # Returns the markedness constraint NoLong.
    def nolong
      @nolong
    end

    # Returns the markedness constraint WSP.
    def wsp
      @wsp
    end

    # Returns the markedness constraint ML.
    def ml
      @ml
    end

    # Returns the markedness constraint MR.
    def mr
      @mr
    end

    # Returns the faithfulness constraint IDStress.
    def idstress
      @idstress
    end

    # Returns the faithfulness constraint IDLength.
    def idlength
      @idlength
    end

    # Accepts parameters of a morph_word and a lexicon. It builds an input form
    # by concatenating the syllables of the underlying forms of each of the
    # morphemes in the morph_word, in order. It also constructs the
    # correspondence relation between the underlying forms of the lexicon and
    # the input, with an entry for each corresponding pair of
    # underlying/input syllables.
    def input_from_morphword(mw, lexicon)
      input = Input.new
      input.morphword = mw
      mw.each do |m| # for each morpheme in the morph_word, in order
        lex_entry = lexicon.find { |entry| entry.morpheme == m } # get the lexical entry
        raise "Morpheme #{m.label} has no lexical entry." if lex_entry.nil?

        uf = lex_entry.uf  # get the underlying form
        raise "The lexical entry for morpheme #{m.label} has no underlying form." if uf.nil?

        uf.each do |syl| # for each syllable of the underlying form
          in_syl = syl.dup
          # add a duplicate of the underlying syllable to input.
          input.push(in_syl)
          # create a correspondence between underlying and input syllables.
          input.ui_corr.add_corr(syl, in_syl)
        end
      end
      input
    end

    # gen takes an input, generates all candidate words for that input, and
    # returns the candidates in an array. All candidates share the same input
    # object. The outputs may also share some of their syllable objects.
    def gen(input)
      # full input, but empty output, io_corr
      start_rep = Word.new(self, input)
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
        no_stress_yet = []
        main_stress_assigned = []
        # iterate over old_no_stress_yet, for each member create a new candidate
        # for each of the ways of adding the next syllable.
        old_no_stress_yet.each do |w|
          no_stress_yet << extend_word_output(w, isyl) { |s| s.set_unstressed.set_short }
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_main_stress.set_short }
          no_stress_yet << extend_word_output(w, isyl) { |s| s.set_unstressed.set_long }
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_main_stress.set_long }
        end
        # iterate over old_main_stress_assigned, for each member create
        # a new candidate for each of the ways of adding the next syllable.
        old_main_stress_assigned.each do |w|
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_unstressed.set_short }
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_unstressed.set_long }
        end
      end

      # Put actual candidates into an array, calling eval on each to set
      # the constraint violations.
      candidates = []
      main_stress_assigned.each do |c|
        c.eval
        candidates.push(c)
      end
      candidates
    end

    # Constructs a full structural description for the given output using the
    # given lexicon. The constructed input will stand in
    # 1-to-1 IO correspondence with the output; an exception is thrown if
    # the number of syllables in the lexical entry of each morpheme doesn't
    # match the number of syllables for that morpheme in the output.
    def parse_output(output, lexicon)
      mw = output.morphword
      # If any morphemes aren't currently in the lexicon, create new entries, with
      # the same number of syllables as in the output, and all features unset.
      mw.each do |m|
        unless lexicon.any? { |entry| entry.morpheme == m }
          under = Underlying.new
          # create a new UF syllable for each syllable of m in the output
          syls_of_m = output.find_all { |syl| syl.morpheme == m }
          syls_of_m.each { |x| under << Syllable.new.set_morpheme(m) }
          lexicon << Lexical_Entry.new(m, under)
        end
      end
      # Construct the input form
      input = input_from_morphword(mw, lexicon)
      word = Word.new(self, input, output)
      # create 1-to-1 IO correspondence
      if input.size != output.size
        raise "Input size #{input.size} not equal to output size #{output.size}."
      end

      # Iterate over successive input and output syllables, adding each
      # pair to the word's correspondence relation.
      input.each_with_index do |in_syl, idx|
        out_syl = output[idx]
        word.add_to_io_corr(in_syl, out_syl)
        if in_syl.morpheme != out_syl.morpheme
          raise "Input syllable morph #{in_syl.morpheme.label} != " +
                "output syllable morph #{out_syl.morpheme.label}"
        end
      end
      word.eval # compute the number of violations of each constraint
      word
    end

    private

    # This defines the constraints, and stores each in the appropriate
    # class variable.
    def initialize_constraints
      @nolong = Constraint.new('NoLong', 1, MARK) do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? then sum + 1 else sum end
        end
      end
      @wsp = Constraint.new('WSP', 2, MARK) do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? && syl.unstressed? then sum + 1 else sum end
        end
      end
      @ml = Constraint.new('ML', 3, MARK) do |cand|
        viol_count = 0
        for syl in cand.output do
          break if syl.main_stress?
          viol_count += 1
        end
        viol_count
      end
      @mr = Constraint.new('MR', 4, MARK) do |cand|
        viol_count = 0
        stress_found = false
        for syl in cand.output do
          viol_count += 1 if stress_found
          stress_found = true if syl.main_stress?
        end
        viol_count
      end
      @idstress = Constraint.new('IDStress', 5, FAITH) do |cand|
        viol_count = 0
        cand.input.each do |in_syl|
          unless in_syl.stress_unset?
            out_syl = cand.io_out_corr(in_syl)
            viol_count += 1 if (in_syl.main_stress? != out_syl.main_stress?)
          end
        end
        viol_count
      end
      @idlength = Constraint.new('IDLength', 6, FAITH) do |cand|
        viol_count = 0
        cand.input.each do |in_syl|
          unless in_syl.length_unset?
            out_syl = cand.io_out_corr(in_syl)
            viol_count += 1 if (in_syl.long? != out_syl.long?)
          end
        end
        viol_count
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
      list
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
      new_w.add_to_io_corr(in_syl, out_syl)
      new_w
    end
  end

  # The system object for the linguistic system SL (stress-length).
  SYSTEM = System.instance
end

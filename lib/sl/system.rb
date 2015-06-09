# Author: Bruce Tesar
#
 
require 'singleton'
require 'REXML/syncenumerator'
require_relative '../constraint_eval'
require_relative '../ui_correspondence'
require_relative '../word'
require_relative '../competition'

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
    # This is strictly for convenience, so that the "Constraint_eval::"
    # prefix doesn't have to appear in the constraint definitions below.
    # Note: done this way because constants cannot be aliased.

    # Indicates that a constraint is a markedness constraint.
    MARK = Constraint_eval::MARK
    # Indicates that a constraint is a faithfulness constraint.
    FAITH = Constraint_eval::FAITH

    # Creates the constraint list and freezes it, as well as freezing
    # each of the constraints. Creation of <em>constraint_list</em>
    # also initializes the constraint attributes (nolong(), etc.).
    def initialize
      initialize_eval_procs
      @constraints = constraint_list # private method creating the list
      @constraints.each {|con| con.freeze} # freeze the constraints
      @constraints.freeze # freeze the constraint list
    end

    # Returns the list of constraints (each constraint is a Constraint object).
    # Note that the returned list is frozen, as are the constraints that
    # it contains.
    def constraints() return @constraints end

    # Returns the markedness constraint nolong.
    def nolong() return @nolong end
    # Returns the markedness constraint wsp.
    def wsp() return @wsp end
    # Returns the markedness constraint ml.
    def ml() return @ml end
    # Returns the markedness constraint mr.
    def mr() return @mr end
    # Returns the faithfulness constraint idstress.
    def idstress() return @idstress end
    # Returns the faithfulness constraint idlength.
    def idlength() return @idlength end

    # Accepts parameters of a morph_word and a grammar. It builds an input form
    # by concatenating the syllables of the underlying forms of each of the
    # morphemes in the morph_word, in order. It also constructs the correspondence
    # relation for the input, with an entry for each corresponding pair of
    # underlying/input syllables.
    def input_from_morphword(mw, gram)
      input = Input.new
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

    #
    # The constraint evaluation procedure declarations.
    #

    def nolong_eval() return @nolong_eval end
    def wsp_eval() return @wsp_eval end
    def ml_eval() return @ml_eval end
    def mr_eval() return @mr_eval end
    def idstress_eval() return @idstress_eval end
    def idlength_eval() return @idlength_eval end

    private

    def initialize_eval_procs
      # NoLong
      @nolong_eval = lambda do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? then sum+1 else sum end
        end
      end
      # WSP
      @wsp_eval = lambda do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? && syl.unstressed? then sum+1 else sum end
        end
      end
      # ML
      @ml_eval = lambda do |cand|
        viol_count = 0
        for syl in cand.output do
          break if syl.main_stress?
          viol_count += 1
        end
        viol_count
      end
      # MR
      @mr_eval = lambda do |cand|
        viol_count = 0
        stress_found = false
        for syl in cand.output do
          viol_count += 1 if stress_found
          stress_found = true if syl.main_stress?
        end
        viol_count
      end
      # IDStress
      @idstress_eval = lambda do |cand|
        cand.io_corr.inject(0) do |sum, pair|
          if pair[0].stress_unset? then sum
          elsif pair[0].main_stress?!=pair[1].main_stress? then sum+1
          else sum
          end
        end
      end
      # IDLength
      @idlength_eval = lambda do |cand|
        cand.io_corr.inject(0) do |sum, pair|
          if pair[0].length_unset? then sum
          elsif pair[0].long?!=pair[1].long? then sum+1
          else sum
          end
        end
      end
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

    # Define the constraint list.
    # Each constraint has a label, a number, and a string defining the
    # violation evaluation procedure. Passing the eval string as an argument
    # to #eval will return a reference to a Proc, itself the actual violation
    # evaluation procedure. Calling that Proc with a candidate will
    # return the number of violations of that constraint in the candidate.
    def constraint_list
      list = []
      list << @nolong = Constraint_eval.new("NoLong", 1, MARK, "SL::System.instance.nolong_eval")
      list << @wsp = Constraint_eval.new("WSP", 2, MARK, "SL::System.instance.wsp_eval")
      list << @ml = Constraint_eval.new("ML", 3, MARK, "SL::System.instance.ml_eval")
      list << @mr = Constraint_eval.new("MR", 4, MARK, "SL::System.instance.mr_eval")
      list << @idstress = Constraint_eval.new("IDStress", 5, FAITH, "SL::System.instance.idstress_eval")
      list << @idlength = Constraint_eval.new("IDLength", 6, FAITH, "SL::System.instance.idlength_eval")
      return list
    end

  end # class SL::System

  # The system object for the linguistic system SL (stress-length).
  SYSTEM = System.instance

end # module SL
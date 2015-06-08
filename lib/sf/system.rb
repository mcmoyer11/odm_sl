# Author: Crystal Akers, from Bruce Tesar's sl/system
#

require 'singleton'
require 'REXML/syncenumerator'
require_relative 'sf_word'
require_relative 'foot'
require_relative 'output_syllable'
require_relative 'sf_output'
require_relative '../constraint_eval'
require_relative '../ui_correspondence'
require_relative '../rubot'
require 'competition'

module SF

  # Contains the core elements of the SF (stress-feet) linguistic system.
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

    # Returns the markedness constraint lmost.
    def lmost() return @lmost end
    # Returns the markedness constraint rmost.
    def rmost() return @rmost end
    # Returns the markedness constraint afl.
    def afl() return @afl end
    # Returns the markedness constraint parsyl.
    def parsyl() return @parsyl end
    # Returns the markedness constraint ftbin.
    def ftbin() return @ftbin end
    # Returns the markedness constraint fnf.
    def fnf() return @fnf end
    # Returns the markedness constraint iamb.
    def iamb() return @iamb end
    # Returns the markedness constraint lapse.
    def lapse() return @lapse end
    # Returns the faithfulness constraint maxstress.
    def maxstress() return @maxstress end

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
      #Creates all of the outputs equal in length to the input, then creates new
      #words with each of these outputs.
      start_rep = SF::Sf_output.new
      # create a list of partial outputs
      not_long_enough = [start_rep]
      final_output_list = [] #List of complete outputs, each containing main stress

      # Create the list of all syllables and feet that can appear in a word.
      element_list = []
      element_list << Output_Syllable.new.set_unstressed #unstressed element
      # degenerate feet
      element_list << Foot.new(Output_Syllable.new.set_main_stress)
      element_list << Foot.new(Output_Syllable.new.set_sec_stress)
      # trochaic and iambic primary feet
      element_list << Foot.new(Output_Syllable.new.set_main_stress,Output_Syllable.new.set_unstressed)
      element_list << Foot.new(Output_Syllable.new.set_unstressed,Output_Syllable.new.set_main_stress)
      # trochaic and iambic secondary feet
      element_list << Foot.new(Output_Syllable.new.set_sec_stress,Output_Syllable.new.set_unstressed)
      element_list << Foot.new(Output_Syllable.new.set_unstressed,Output_Syllable.new.set_sec_stress)

      # Set the word length in syllables
      word_length = input.length

      # Keep processing not_long_enough until no structures remain that need adding
      # on to (that is, have fewer than the required number of syllables).
      until not_long_enough.empty?
        base = not_long_enough.shift # take the first output in the queue
        # Separately extend copies of the base output with each possible word element.
        element_list.each do |el|
          next_output = base # Copy the partial output
          # Extends next_output with the word element el unless both already include
          # main stress.
          # If the newly extended output is long enough and contains main stress,
          # it is moved to the final_output_list. Otherwise, if it is not yet long enough,
          # then it is added to the back of not_long_enough to be extended further.
          unless (next_output.any? {|element| element.main_stress?}) and el.main_stress? then
            extended_out = extend_output(next_output, el)
            if extended_out.syllable_count == word_length and (extended_out.any? {|element| element.main_stress?}) then
              final_output_list << extended_out
            elsif extended_out.syllable_count < word_length then
              not_long_enough << extended_out
            end
          end
        end
      end

      # Create a new word for each of the completed outputs
      final_word_list = []
      final_output_list.each do |output|
        #Creates a new word with full input, but empty output, io_corr
        new_word = Sf_word.new(SYSTEM,input,output)
        new_word.output.morphword = input.morphword
        # Sets the morpheme of the output syllable equal to the morpheme of the input syllable
        # Also sets the io_corr pairs for the input and output syllables
        g = REXML::SyncEnumerator.new(input,output.syl_list)
        g.each do |in_syl,out_syl|
          out_syl.set_morpheme(in_syl.morpheme)
          new_word.io_corr << [in_syl,out_syl]
        end
        final_word_list << new_word
      end

      # Put actual candidates into competition, calling eval on each to set
      # the constraint violations.
      competition = Competition.new
      final_word_list.each{|c| c.eval; competition.push(c)}
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
          output.each_syllable do |syl|
            if syl.morpheme == m then
              under << SF::Syllable.new.set_morpheme(m)
            end
          end
          gram.lexicon << Lexical_Entry.new(m,under)
        end
      end
      # Construct the input form
      input = input_from_morphword(mw, gram)
      word = Sf_word.new(SYSTEM,input,output)
      # create 1-to-1 IO correspondence
      if input.size != output.syllable_count then
        raise "Input size #{input.size} not equal to output size #{output.syllable_count}."
      end
      gen = REXML::SyncEnumerator.new(input, output.syl_list)
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

    # Constructs a list containing all the outputs that correspond to the given overt form.
    def parse_overt(overt, gram)
      # Construct the structural interpretations by creating two lists of partial
      # interpretations. Interpretations in openft are incomplete: each ends with
      #  a syllable that could be parsed into a foot. Interpretations in closedft
      # are complete: they end with either a foot or an unparsed syllable that will remain
      # unparsed.
      closedft =[]; openft =[]
      overt.each do |syl|
        # copy the partial interpretation lists to old_*, and reset the lists to empty.
        old_clft = closedft; old_opft = openft
        closedft =[]; openft =[]
        # If old_opft is empty and syl is unstressed, add an interpretation with
        # syl as the first syllable of an incomplete foot
        if old_opft.empty? and syl.unstressed? then
          interp = Sf_output.new
          interp << syl
          openft << interp.dup
        else
          # Otherwise, for each interpretation, check that the last syllable of the
          # interpretation and syl are not both stressed or unstressed. If they have different
          # stress feature values, extended the interpretation with a binary foot
          # using last_syllable and syl. If they have the same stress values, do nothing
          # (eliminate this partial interpretation, because it will be a duplicate
          # of a partial interpretation in the closedft list).
          until old_opft.empty?
            interp = Sf_output.new
            i = old_opft.shift
            last_syllable = i.pop
            unless syl.stressed? == last_syllable.stressed? then
              # Copy each remaining element in i and add to interp. Also complete the binary foot
              # by extending the last syllable with syl.
              unless i.empty?
                i.each { |el| interp << el }
              end
              interp << Foot.new(last_syllable, syl)
              # With the completed foot, the interpretation is added to the closedft list
              closedft << interp.dup
            end
          end
        end
        # If old_clft is empty, add an interpretation with syl as the first closed element --
        # either an unparsed syllable or a unary foot.
        if old_clft.empty? then
          interp = Sf_output.new
          if syl.stressed? then
            open_interp = Sf_output.new
            open_interp << syl
            openft << open_interp.dup
            interp << Foot.new(syl)
            closedft << interp.dup
          else
            interp << syl
            closedft <<  interp.dup
          end
        else
          # Extend each old closed interpretation with another closed element (either an
          # unparsed syllable or a binary foot. Also extend with an open element (either
          # the beginning of an iamb or a trochee, depending on syl.
          until old_clft.empty?
            i = old_clft.shift
            interp = Sf_output.new
            # copy each element in i and add to interp. Also copy and add syl to begin the
            # potential binary foot.
            i.each do |el|
              interp << el
            end
            open_interp = Sf_output.new
            open_interp = interp.dup << syl
            openft << open_interp.dup
            if syl.stressed? then
              interp << Foot.new(syl)
            else
              interp << syl
            end
            closedft << interp.dup
          end
        end
      end
      # Closedft will contain all completely parsed interpretations. Each of these
      # must have the same morphword as the overt form.
      closedft.each do |i|
        i.morphword = overt.morphword
      end
      # If a code block was given, run it on each interpretation given.
      closedft.each {|interp| yield interp} if block_given?
      return closedft
    end

    # Returns a list of the words whose outputs are structural interpretations
    # of the given overt form.
    def get_interpretations(overt,gram)
      output_list = parse_overt(overt,gram)
      list = []
      output_list.each do |output|
        list << parse_output(output,gram)
      end
      return list
    end

    # The constraint evaluation procedure declarations.
    #
    def lmost_eval() return @lmost_eval end
    def rmost_eval() return @rmost_eval end
    def afl_eval() return @afl_eval end
    def parsyl_eval() return @parsyl_eval end
    def ftbin_eval() return @ftbin_eval end
    def fnf_eval() return @fnf_eval end
    def iamb_eval() return @iamb_eval end
    def lapse_eval() return @lapse_eval end
    def maxstress_eval() return @maxstress_eval end

    private


    def initialize_eval_procs
      # LMost
      @lmost_eval = lambda do |cand|
        viol_count = 0
        cand.output.each_element do |el|
          break if el.main_stress?
          viol_count += el.syllable_count
        end
        viol_count
      end
      # RMost
      @rmost_eval = lambda do |cand|
        viol_count = 0
        stress_found = false
        cand.output.each_element do |el|
          viol_count += el.syllable_count if stress_found
          stress_found = true if el.main_stress?
        end
        viol_count
      end
      # AFL
      @afl_eval = lambda do |cand|
        viol_count = 0
        cand.output.each_index do |ind|
          # For each foot, add up the number of syllables in the slice of output
          # to the left of the foot
          if ind > 0 and cand.output[ind].class == Foot then
            output_slice = cand.output.slice(0..ind-1)
            output_slice.each { |el| viol_count += el.syllable_count }
          end
        end
        viol_count
      end
      # ParSyl
      @parsyl_eval = lambda do |cand|
        viol_count = 0
        cand.output.each_element do |el|
          viol_count += 1 if el.class != Foot
        end
        viol_count
      end
      # FtBin
      @ftbin_eval = lambda do |cand|
        viol_count = 0
        cand.output.each_element do |el|
          viol_count += 1 if el.class == Foot and el.syllable_count ==1
        end
        viol_count
      end
      # FNF
      @fnf_eval = lambda do |cand|
        viol_count = 0
        cand.output.each_element do |el|
          viol_count +=1 if el.class == Foot and el.last_syl.stressed?
        end
        viol_count
      end
      # Iamb
      @iamb_eval = lambda do |cand|
        viol_count = 0
        cand.output.each_element do |el|
          viol_count += 1 if el.class == Foot and !el.last_syl.stressed?
        end
        viol_count
      end
      # Lapse
      @lapse_eval = lambda do |cand|
        viol_count = 0
        cand.output.syl_list.each_index do |ind|
          unless cand.output.syl_list[ind].equal?cand.output.syl_list[-1]
            viol_count += 1 if cand.output.syl_list[ind].unstressed? and !cand.output.syl_list[ind+1].stressed?
          end
        end
        viol_count
      end
      # MaxStress
      @maxstress_eval = lambda do |cand|
        cand.io_corr.inject(0) do |sum, pair|
          if pair[0].stress_unset? then sum
          elsif pair[0].main_stress? & !pair[1].main_stress? then sum+1
          else sum
          end
        end
      end
    end

    # Takes a partial output, along with
    # a reference to the next word element (syllable or foot) to be added
    # to the output. A copy of the new output, containing the new output syllable(s)
    #is returned.
    def extend_output(output, el)
      new_output = output.dup
      new_output << el.dup
      return new_output
    end

    # Define the constraint list.
    # Each constraint has a label, a number, and a string defining the
    # violation evaluation procedure. Passing the eval string as an argument
    # to #eval will return a reference to a Proc, itself the actual violation
    # evaluation procedure. Calling that Proc with a candidate will
    # return the number of violations of that constraint in the candidate.
    def constraint_list
      list = []
      list << @lmost = Constraint_eval.new("LMost", 1, MARK, "SF::System.instance.lmost_eval")
      list << @rmost = Constraint_eval.new("RMost", 2, MARK, "SF::System.instance.rmost_eval")
      list << @afl = Constraint_eval.new("AFL", 3, MARK, "SF::System.instance.afl_eval")
      list << @parsyl = Constraint_eval.new("ParSyl", 4, MARK, "SF::System.instance.parsyl_eval")
      list << @ftbin = Constraint_eval.new("FtBin", 5, MARK, "SF::System.instance.ftbin_eval")
      list << @fnf = Constraint_eval.new("FNF", 6, MARK, "SF::System.instance.fnf_eval")
      list << @iamb = Constraint_eval.new("Iamb", 7, MARK, "SF::System.instance.iamb_eval")
      list << @lapse = Constraint_eval.new("Lapse", 8, MARK, "SF::System.instance.lapse_eval")
      list << @maxstress = Constraint_eval.new("MaxStress", 9, FAITH, "SF::System.instance.maxstress_eval")
      return list
    end

  end # class SF::System

  # The system object for the linguistic system SF (stress-feet).
  SYSTEM = System.instance

end # module SF


# Author: Crystal Akers, based on Bruce Tesar's sl/data
#
# This adds, to the module SF, routines for generating data of various types
# within the SF (stress-feet) linguistic system.

require_relative 'system'
require_relative 'grammar'
require_relative 'syllable'
require_relative '../morpheme'
require_relative '../morph_word'
require_relative '../underlying'
require_relative '../lexical_entry'
require_relative '../most_harmonic'
require_relative '../hypothesis'
require_relative '../otlearn/data_manip'
require_relative '../rubot'
require 'competition'
require 'competition_list'
require 'facets/array/product' # Adds cartesian product to class Array.

module SF

  # Returns a list of lexical entries for the possible morphemes
  # of morphological type _type_ with underlying form length
  # _uf_length_ (measured in syllables). Each morpheme is assigned
  # a label with a distinct number, with _id_number_ providing
  # the base (the first generated morpheme gets number _id_number_ + 1,
  # the next generated gets number _id_number_ + 2, etc.).
  # If a code block is given, each generated lexical entry is passed to it.
  def SF.generate_morphemes(uf_length, type, id_number)
    if type==Morpheme::ROOT then label_pref = "r"
    elsif type==Morpheme::PREFIX then label_pref = "p"
    elsif type==Morpheme::SUFFIX then label_pref = "s"
    else raise "Unrecognized morpheme type."
    end
    lexical_entry_list = []
    SF.generate_underlying_forms(uf_length) do |uf|
      id_number += 1
      morph = Morpheme.new("#{label_pref}#{id_number.to_s}", type)
      uf.each {|s| s.set_morpheme(morph)}
      lexical_entry_list << Lexical_Entry.new(morph,uf)
    end
    # If a code block was given, run it on each lexical entry.
    lexical_entry_list.each {|le| yield le} if block_given?
    return lexical_entry_list
  end

  # Generates all possible underlying forms with _uf_length_ syllables.
  # If _uf_length_ == 0, a list with a single empty UF is returned.
  # If a code block is given, each UF is passed to it. Note: Syllables in
  # underlying forms can only be unstressed or have main stress.
  def SF.generate_underlying_forms(uf_length)
    raise "UF length cannot be <0!" if uf_length<0
    uf_list = [Underlying.new]
    uf_length.times do
      new_uf_list = []
      SF.generate_syllables do |s|
        uf_list.each do |uf|
          new_uf = (uf.dup << s.dup)
          new_uf_list << new_uf
        end
      end
      uf_list = new_uf_list
    end
    # If a code block was given, run it on each underlying form.
    uf_list.each {|uf| yield uf} if block_given?
    return uf_list
  end

  # Generate all possible syllables (possible combinations of feature values).
  # Note that the sf system include secondary stress as a property of output syllables,
  # not as a feature; therefore, none of the syllables generated will have secondary stress.
  # If a code block is given, each syllable is passed to the code block.
  # Returns a list of the possible syllables.
  def SF.generate_syllables
    syl_list = [] << Syllable.new
    base_syl = Syllable.new
    base_syl.each_feature do |f|
      fresh_syl_list = []
      f.each_value do |v|
        syl_list.each do |s|
          syl = s.dup
          syl.get_feature(f.type).value = v
          fresh_syl_list << syl
        end
      end
      syl_list = fresh_syl_list
    end
    # If a code block was given, run it on each syllable.
    syl_list.each {|s| yield s} if block_given?
    return syl_list
  end
  
  # Generates the optimal candidates with respect to constraint
  # hierarchy _hier_ for each input in _inputs_, using the lexicon
  # in grammar _gram_. The hierarchy in _gram_ is set to _hier_.
  # _gram_ needs to already contain a lexicon with entries for all
  # of the morphemes appearing in the inputs.
  # Returns a list of the optimal candidates of the language.
  def SF.generate_language(hier, inputs, gram)
    competitions = inputs.map{|i| SYSTEM.gen(i)}
    comp_list = Competition_list.new.concat(competitions)
    gram.hierarchy = hier
    comp_mh = comp_list.map{|comp| MostHarmonic.new(comp,gram.hierarchy)}
    # each competition returns a list of winners; collapse to one-level list.
    lang = comp_mh.inject([]){|winners, mh_list| winners.concat(mh_list) }
    lang.each{|winner| winner.assert_opt}
    return lang
  end

  def SF.competitions_from_morphwords(words, gram)
    # Generate the corresponding input for each morphological word
    inputs = words.map{|mw| SYSTEM.input_from_morphword(mw,gram)}
    # Generate the corresponding competition for each input
    competitions = inputs.map{|i| SYSTEM.gen(i)}
    # Convert the array of competitions into a proper Competition_list.
    comp_list = Competition_list.new.concat(competitions)
    comp_list.label = "SF"
    return comp_list
  end

  def SF.generate_competitions_1r1s
    # Generate the morphemes
    roots = SF.generate_morphemes(1, Morpheme::ROOT, 0)
    suffixes = SF.generate_morphemes(1, Morpheme::SUFFIX, 0)
    # Create a new grammar, and add all of the morphemes to the lexicon.
    gram = Grammar.new
    roots.each{|root_le| gram.lexicon.add(root_le)}
    suffixes.each{|suf_le| gram.lexicon.add(suf_le)}
    # Morphology: create all combinations of one root and one suffix
    word_parts = roots.product(suffixes)
    words = word_parts.map do |parts|
      # Add the morphemes of the combination to a new morphological word.
      parts.inject(MorphWord.new){|w,le| w.add(le.morpheme); w}
    end
    # Generate the competition for each morphword
    comp_list = competitions_from_morphwords(words, gram)
    return comp_list, gram
  end

  def SF.generate_competitions_2r1s
    # Generate the morphemes
    roots = SF.generate_morphemes(2, Morpheme::ROOT, 0)
    suffixes = SF.generate_morphemes(1, Morpheme::SUFFIX, 0)
    # Create a new grammar, and add all of the morphemes to the lexicon.
    gram = Grammar.new
    roots.each{|root_le| gram.lexicon.add(root_le)}
    suffixes.each{|suf_le| gram.lexicon.add(suf_le)}
    # Morphology: create all combinations of one root and one suffix
    word_parts = roots.product(suffixes)
    words = word_parts.map do |parts|
      # Add the morphemes of the combination to a new morphological word.
      parts.inject(MorphWord.new){|w,le| w.add(le.morpheme); w}
    end
    # Generate the competition for each morphword
    comp_list = competitions_from_morphwords(words, gram)
    return comp_list, gram
  end

  def SF.generate_default_inputs
    gram = Grammar.new
    # Generate the possible monosyllabic roots and suffixes
    roots = SF.generate_morphemes(1, Morpheme::ROOT, 0)
    suffixes = SF.generate_morphemes(1, Morpheme::SUFFIX, 0)
    # Create all combinations of root-suffix
    # Make sure the roots are first in the cartesian product, because they
    # must be added first when constructing MorphWords.
    word_parts = roots.product(suffixes)
    #
    # Next line: how to include free roots as (monomorphemic) words
    # word_parts += roots.product()
    #
    # Convert each morpheme-tuple into a MorphWord
    words = word_parts.map{|t| t.inject(MorphWord.new){|w,le| w.add(le.morpheme); w}}
    # Add the morphemes to the lexicon
    roots.each{|root_le| gram.lexicon.add(root_le)}
    suffixes.each{|suf_le| gram.lexicon.add(suf_le)}
    # Generate the input for each morph_word.
    inputs = words.map{|mw| SYSTEM.input_from_morphword(mw,gram)}
    return inputs, gram
  end

  #--
  # Data for testing purposes.
  #++

  def SF.generate_words_lang_a
    inputs, gram = SF.generate_default_inputs
    competitions = inputs.map{|i| SYSTEM.gen(i)}
    comp_list = Competition_list.new.concat(competitions)
    winner_list, hyp = OTLearn::generate_learning_data_from_competitions(comp_list, SF.hier_3,Grammar)
    return winner_list, hyp
  end

  def SF.generate_outputs_lang_a
    inputs, gram = SF.generate_default_inputs
    lang = SF.generate_language(SF.hier_2a, inputs, gram)
    outputs = lang.map{|w| w.output}
    return outputs
  end

#--
# Hierarchies
#++

 # Constraints: LMost RMost AFL ParSyl FtBin FNF Iamb Lapse MaxStress

  #Hierarchies 1-6 represent each of the 6 languages in the r1s1 typology
  def SF.hier_1
    hier = Hierarchy.new
    hier << [SYSTEM.lmost] << [SYSTEM.lapse] << [SYSTEM.parsyl] << [SYSTEM.afl] <<
      [SYSTEM.ftbin] << [SYSTEM.rmost] << [SYSTEM.fnf] << [SYSTEM.maxstress] << [SYSTEM.iamb]
    return hier
  end

  def SF.hier_2a
    hier = Hierarchy.new
    hier << [SYSTEM.lmost] << [SYSTEM.lapse] << [SYSTEM.parsyl] << [SYSTEM.afl] <<
      [SYSTEM.ftbin] << [SYSTEM.rmost] << [SYSTEM.maxstress] << [SYSTEM.fnf] << [SYSTEM.iamb]
    return hier
  end

  def SF.hier_3
    hier = Hierarchy.new
    hier << [SYSTEM.lmost] << [SYSTEM.lapse] << [SYSTEM.parsyl] << [SYSTEM.afl] <<
      [SYSTEM.ftbin] << [SYSTEM.rmost] << [SYSTEM.maxstress] << [SYSTEM.iamb] << [SYSTEM.fnf]
    return hier
  end

  def SF.hier_4
    hier = Hierarchy.new
    hier << [SYSTEM.lmost] << [SYSTEM.lapse] << [SYSTEM.parsyl] << [SYSTEM.afl] <<
      [SYSTEM.ftbin] << [SYSTEM.rmost]  << [SYSTEM.iamb] << [SYSTEM.maxstress]<< [SYSTEM.fnf]
    return hier
  end

  def SF.hier_5
    hier = Hierarchy.new
    hier << [SYSTEM.lmost] << [SYSTEM.lapse] << [SYSTEM.afl] << [SYSTEM.maxstress] <<
      [SYSTEM.iamb] << [SYSTEM.fnf]  << [SYSTEM.parsyl] << [SYSTEM.ftbin]<< [SYSTEM.rmost]
    return hier
  end

  def SF.hier_6
    hier = Hierarchy.new
    hier << [SYSTEM.lmost] << [SYSTEM.lapse] << [SYSTEM.parsyl] << [SYSTEM.maxstress] <<
      [SYSTEM.iamb] << [SYSTEM.fnf]  << [SYSTEM.ftbin] << [SYSTEM.afl]<< [SYSTEM.rmost]
    return hier
  end

  # This is the hierarchy for language 66 in the r2s1 typology
  def SF.hier_66
    hier = Hierarchy.new
    hier << [SYSTEM.maxstress] << [SYSTEM.iamb] << [SYSTEM.rmost] << [SYSTEM.lmost] <<
      [SYSTEM.afl] << [SYSTEM.parsyl]  << [SYSTEM.lapse] << [SYSTEM.fnf]<< [SYSTEM.ftbin]
    return hier
  end

  # This is the hierarchy for language 58 in the r2s1 typology
  def SF.hier_58
    hier = Hierarchy.new
    hier << [SYSTEM.lapse] << [SYSTEM.parsyl] << [SYSTEM.lmost] << [SYSTEM.ftbin] <<
      [SYSTEM.fnf] << [SYSTEM.rmost] << [SYSTEM.maxstress] << [SYSTEM.iamb]<< [SYSTEM.afl]
    return hier
  end

  # This is the hierarchy for language 55 in the r2s1 typology
  def SF.hier_55
    hier = Hierarchy.new
    hier << [SYSTEM.lapse] << [SYSTEM.maxstress] << [SYSTEM.lmost] <<  [SYSTEM.fnf] <<
      [SYSTEM.rmost] << [SYSTEM.parsyl] << [SYSTEM.iamb] << [SYSTEM.ftbin] << [SYSTEM.afl]
    return hier
  end

    # This is the hierarchy for language 2 in the r2s1 typology
  def SF.hier_2
    hier = Hierarchy.new
    hier << [SYSTEM.iamb]<< [SYSTEM.ftbin] << [SYSTEM.fnf] << [SYSTEM.parsyl] <<
      [SYSTEM.maxstress] << [SYSTEM.rmost] << [SYSTEM.afl] << [SYSTEM.lmost] << [SYSTEM.lapse]
    return hier
  end

     # This is the hierarchy for language 3 in the r2s1 typology
  def SF.hier_3
    hier = Hierarchy.new
    hier << [SYSTEM.rmost] << [SYSTEM.ftbin] << [SYSTEM.afl] << [SYSTEM.lmost] <<
        [SYSTEM.parsyl] << [SYSTEM.maxstress] << [SYSTEM.iamb] << [SYSTEM.fnf]<< [SYSTEM.lapse]
    return hier
  end

  # This is the hierarchy for language 37 in the r2s1 typology
  def SF.hier_37
    hier = Hierarchy.new
    hier  << [SYSTEM.maxstress] << [SYSTEM.ftbin] << [SYSTEM.parsyl] << [SYSTEM.lapse]<<
      [SYSTEM.rmost]<< [SYSTEM.fnf]<< [SYSTEM.iamb] << [SYSTEM.afl] << [SYSTEM.lmost]
    return hier
  end

  # This is the hierarchy for language 37 in the r2s1 typology
  def SF.hier_88
    hier = Hierarchy.new
    hier  << [SYSTEM.maxstress] << [SYSTEM.rmost]<< [SYSTEM.lmost]<< [SYSTEM.afl] <<
    [SYSTEM.lapse] << [SYSTEM.parsyl] << [SYSTEM.ftbin] << [SYSTEM.fnf]<< [SYSTEM.iamb]
    return hier
  end

    # This is the hierarchy for language 39 in the r2s1 typology
  def SF.hier_39
    hier = Hierarchy.new
    hier <<  [SYSTEM.ftbin] << [SYSTEM.fnf] << [SYSTEM.parsyl] << [SYSTEM.iamb] <<
      [SYSTEM.maxstress] << [SYSTEM.rmost] << [SYSTEM.lapse] << [SYSTEM.afl] << [SYSTEM.lmost]
    
    return hier
  end

  # This is the hierarchy for language 13 in the r2s1 typology
  def SF.hier_13
    hier = Hierarchy.new
    hier  << [SYSTEM.maxstress] << [SYSTEM.lmost]<< [SYSTEM.afl]<< [SYSTEM.ftbin] <<
      [SYSTEM.rmost] << [SYSTEM.parsyl] << [SYSTEM.lapse]<< [SYSTEM.fnf] << [SYSTEM.iamb]
    return hier
  end

end # module SF
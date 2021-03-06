# Author: Bruce Tesar
#
# This adds, to the module SL, routines for generating data of various types
# within the SL (stress-length) linguistic system.

require_relative 'system'
require_relative 'syllable'
require_relative '../grammar'
require_relative '../morpheme'
require_relative '../morph_word'
require_relative '../underlying'
require_relative '../lexical_entry'
require_relative '../otlearn/data_manip'

module SL

  # Returns a list of lexical entries for the possible morphemes
  # of morphological type _type_ with underlying form length
  # _uf_length_ (measured in syllables). Each morpheme is assigned
  # a label with a distinct number, with _id_number_ providing
  # the base (the first generated morpheme gets number _id_number_ + 1,
  # the next generated gets number _id_number_ + 2, etc.).
  # If a code block is given, each generated lexical entry is passed to it.
  def SL.generate_morphemes(uf_length, type, id_number)
    if type==Morpheme::ROOT then label_pref = "r"
    elsif type==Morpheme::PREFIX then label_pref = "p"
    elsif type==Morpheme::SUFFIX then label_pref = "s"
    else raise "Unrecognized morpheme type."
    end
    lexical_entry_list = []
    SL.generate_underlying_forms(uf_length) do |uf|
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
  # If a code block is given, each UF is passed to it.
  def SL.generate_underlying_forms(uf_length)
    raise "UF length cannot be <0!" if uf_length<0
    uf_list = [Underlying.new]
    uf_length.times do
      new_uf_list = []
      SL.generate_syllables do |s|
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
  # If a code block is given, each syllable is passed to the code block.
  # Returns a list of the possible syllables.
  def SL.generate_syllables
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
  
  # Given a list of morphwords _words_ and a grammar _gram_, this constructs
  # the input for each morphword, generates the competition for each input,
  # and returns the list of competitions.
  def SL.competitions_from_morphwords(words, gram)
    lexicon = gram.lexicon
    # Generate the corresponding input for each morphological word
    inputs = words.map{|mw| SYSTEM.input_from_morphword(mw,lexicon)}
    # Generate the corresponding competition for each input
    competitions = inputs.map{|i| SYSTEM.gen(i)}
    return competitions
  end

  # Generates a list of competitions, one for each possible input of
  # a prescribed paradigm. This can be used, for instance, to generate
  # winners via OTLearn.generate_language_from_competitions().
  #
  # This method generates the paradigm 1r1s, with all of the possible
  # 1-syllable roots and all of the possible 1-syllable suffixes, and
  # words formed from all possible root+suffix combinations.
  def SL.generate_competitions_1r1s
    # Generate the morphemes
    roots = SL.generate_morphemes(1, Morpheme::ROOT, 0)
    suffixes = SL.generate_morphemes(1, Morpheme::SUFFIX, 0)
    # Create a new grammar, and add all of the morphemes to the lexicon.
    gram = Grammar.new(system: SL::System.instance)
    roots.each{|root_le| gram.lexicon.add(root_le)}
    suffixes.each{|suf_le| gram.lexicon.add(suf_le)}
    # Morphology: create all combinations of one root and one suffix
    word_parts = roots.product(suffixes)
    # Next line: how to include free roots as (monomorphemic) words
    # word_parts += roots.product()
    words = word_parts.map do |parts|
      # Add the morphemes of the combination to a new morphological word.
      parts.inject(MorphWord.new){|w,le| w.add(le.morpheme); w}
    end
    # Generate the competition for each morphword
    comp_list = competitions_from_morphwords(words, gram)
    return comp_list
  end
  
  # Generates a list of competitions, one for each possible input of
  # a prescribed paradigm. This can be used, for instance, to generate
  # winners via OTLearn.generate_language_from_competitions().
  #
  # This method generates the paradigm 2r1s, with all of the possible
  # 2-syllable roots and all of the possible 1-syllable suffixes, and
  # words formed from all possible root+suffix combinations.
  def SL.generate_competitions_2r1s
    # Generate the morphemes
    roots = SL.generate_morphemes(2, Morpheme::ROOT, 0)
    suffixes = SL.generate_morphemes(1, Morpheme::SUFFIX, 0)
    # Create a new grammar, and add all of the morphemes to the lexicon.
    gram = Grammar.new(system: SL::System.instance)
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
    return comp_list
  end

  # Generates a list of competitions, one for each possible input of
  # a prescribed paradigm. This can be used, for instance, to generate
  # winners via OTLearn.generate_language_from_competitions().
  #
  # This method generates the paradigm 1p2r, with all of the possible
  # 1-syllable prefixes and all of the possible 2-syllable roots, and
  # words formed from all possible prefix+root combinations.
  def SL.generate_competitions_1p_2r
      # Generate the morphemes
      roots = SL.generate_morphemes(2, Morpheme::ROOT, 0)
      prefixes = SL.generate_morphemes(1, Morpheme::PREFIX, 0)
      # Create a new grammar, and add all of the morphemes to the lexicon.
      gram = Grammar.new(system: SL::System.instance)
      roots.each{|root_le| gram.lexicon.add(root_le)}
      prefixes.each{|pre_le| gram.lexicon.add(pre_le)}
      # Morphology: create all combinations of one root and one prefix
      word_parts = roots.product(prefixes)
      words = word_parts.map do |parts|
        # Add the morphemes of the combination to a new morphological word.
        parts.inject(MorphWord.new){|w,le| w.add(le.morpheme); w}
      end
      # Generate the competition for each morphword
      comp_list = competitions_from_morphwords(words, gram)
      return comp_list
  end
end

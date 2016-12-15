# Author: Morgan Moyer
#
# This adds, to the module PAS, routines for generating data of various types
# within the PAS (stress-length) linguistic system.

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
require_relative '../competition'
require_relative '../competition_list'

module PAS

  # Returns a list of lexical entries for the possible morphemes
  # of morphological type _type_ with underlying form length
  # _uf_length_ (measured in syllables). Each morpheme is assigned
  # a label with a distinct number, with _id_number_ providing
  # the base (the first generated morpheme gets number _id_number_ + 1,
  # the next generated gets number _id_number_ + 2, etc.).
  # If a code block is given, each generated lexical entry is passed to it.
  def PAS.generate_morphemes(uf_length, type, id_number)
    if type==Morpheme::ROOT then label_pref = "r"
    elsif type==Morpheme::PREFIX then label_pref = "p"
    elsif type==Morpheme::SUFFIX then label_pref = "s"
    else raise "Unrecognized morpheme type."
    end
    lexical_entry_list = []
    PAS.generate_underlying_forms(uf_length) do |uf|
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
  def PAS.generate_underlying_forms(uf_length)
    raise "UF length cannot be <0!" if uf_length<0
    uf_list = [Underlying.new]
    uf_length.times do
      new_uf_list = []
      PAS.generate_syllables do |s|
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
  def PAS.generate_syllables
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
  def PAS.generate_language(hier, inputs, gram)
    competitions = inputs.map{|i| SYSTEM.gen(i)}
    comp_list = Competition_list.new.concat(competitions)
    gram.hierarchy = hier
    comp_mh = comp_list.map{|comp| MostHarmonic.new(comp,gram.hierarchy)}
    # each competition returns a list of winners; collapse to one-level list.
    lang = comp_mh.inject([]){|winners, mh_list| winners.concat(mh_list) }
    lang.each{|winner| winner.assert_opt}
    return lang
  end

  # Given a list of morphwords _words_ and a grammar _gram_, this constructs
  # the input for each morphword, generates the competition for each input,
  # and returns the list of competitions.
  def PAS.competitions_from_morphwords(words, gram)
    # Generate the corresponding input for each morphological word
    inputs = words.map{|mw| SYSTEM.input_from_morphword(mw,gram)}
    # Generate the corresponding competition for each input
    competitions = inputs.map{|i| SYSTEM.gen(i)}
    # Convert the array of competitions into a proper Competition_list.
    comp_list = Competition_list.new.concat(competitions)
    comp_list.label = "PAS"
    return comp_list
  end

  # Generates a list of competitions and a grammar with a lexicon of
  # corresponding morphemes. This can be used, for instance, to generate
  # learning data via OTLearn.generate_learning_data_from_competitions().
  #
  # This method generates the paradigm 1r1s, with all of the possible
  # 1-syllable roots and all of the possible 1-syllable suffixes, and
  # words formed from all possible root+suffix combinations.
  def PAS.generate_competitions_1r1s
    # Generate the morphemes
    roots = PAS.generate_morphemes(1, Morpheme::ROOT, 0)
    suffixes = PAS.generate_morphemes(1, Morpheme::SUFFIX, 0)
    # Create a new grammar, and add all of the morphemes to the lexicon.
    gram = Grammar.new
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
    return comp_list, gram
  end
  
  # Generates a list of competitions and a grammar with a lexicon of
  # corresponding morphemes. This can be used, for instance, to generate
  # learning data via OTLearn.generate_learning_data_from_competitions().
  #
  # This method generates the paradigm 2r1s, with all of the possible
  # 2-syllable roots and all of the possible 1-syllable suffixes, and
  # words formed from all possible root+suffix combinations.
  def PAS.generate_competitions_2r1s
    # Generate the morphemes
    roots = PAS.generate_morphemes(2, Morpheme::ROOT, 0)
    suffixes = PAS.generate_morphemes(1, Morpheme::SUFFIX, 0)
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

  # Generates a list of competitions and a grammar with a lexicon of
  # corresponding morphemes. This can be used, for instance, to generate
  # learning data via OTLearn.generate_learning_data_from_competitions().
  #
  # This method generates the paradigm 1p2r, with all of the possible
  # 1-syllable prefixes and all of the possible 2-syllable roots, and
  # words formed from all possible prefix+root combinations.
  def PAS.generate_competitions_1p_2r
      # Generate the morphemes
      roots = PAS.generate_morphemes(2, Morpheme::ROOT, 0)
      prefixes = PAS.generate_morphemes(1, Morpheme::PREFIX, 0)
      # Create a new grammar, and add all of the morphemes to the lexicon.
      gram = Grammar.new
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
      return comp_list, gram
  end

#--
# Hierarchies
#++

  # The hierarchy for Language A, also known as L20 (in the typology).
  def PAS.hier_a
    hier = Hierarchy.new
    hier << [SYSTEM.wsp] << [SYSTEM.idstress] << [SYSTEM.ml] <<
      [SYSTEM.mr] << [SYSTEM.idlength] << [SYSTEM.nolong]
    return hier
  end
end # module PAS

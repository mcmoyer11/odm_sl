# Author: Bruce Tesar
#

require_relative 'system'
require_relative '../lexicon'

module SL

  # A grammar for the SL linguistic system consists of a reference to
  # the SL::System linguistic system and a lexicon.
  class Grammar
    
    # The lexicon for the grammar.
    attr_accessor :lexicon

    # Stores the linguistic system associated with this grammar.
    # In this case, the SL (stress-length) linguistic system.
    @@system = System.instance

    # Returns a new grammar. If a lexicon is not provided as a parameter,
    # the default initial lexicon is empty.
    def initialize(lex=Lexicon.new)
      @lexicon = lex
    end

    # Returns a reference to the linguistic system associated with this grammar.
    def system
      @@system
    end

    # Returns a deep copy of the grammar, with a duplicates of the lexicon.
    # The duplicate of the lexicon contains duplicates of the lexical entries,
    # and the duplicate lexical entries contain duplicates of the underlying
    # forms but references to the very same morpheme objects.
    def dup
      return self.class.new(@lexicon.dup)
    end

    # Returns a shallow copy of the grammar, with a reference to the very
    # same lexicon object.
    def dup_shallow
      return self.class.new(@lexicon)
    end

    # Returns the underlying form for the given morpheme, as stored in
    # the grammar's lexicon. Returns nil if the morpheme does not appear
    # in the lexicon.
    def get_uf(morph)
      lex_entry = @lexicon.find{|entry| entry.morpheme==morph} # get the lexical entry
      return nil if lex_entry.nil?
      return lex_entry.uf  # return the underlying form
    end

  end # class Grammar

end # module SL
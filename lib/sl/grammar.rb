# Author: Bruce Tesar
#

require_relative 'system'
require_relative '../lexicon'

module SL

  # A grammar for the SL linguistic system consists of a reference to
  # the SL::System linguistic system and a lexicon.
  class Grammar
    
    # The list of ercs defining the ranking information of the grammar.
    attr_reader :erc_list
    
    # The lexicon for the grammar.
    attr_reader :lexicon

    # The linguistic system associated with this grammar.
    attr_reader :system

    # Returns a new grammar.
    # The default initial ERC list and lexicon are empty.
    # The default linguistic system is SL::System.
    def initialize(erc_list: nil, lexicon: Lexicon.new, system: System.instance)
      @system = system
      @erc_list = erc_list
      @erc_list ||= Comparative_tableau.new("SL::Grammar", @system.constraints)
      @lexicon = lexicon
    end

    # Returns a deep copy of the grammar, with a duplicates of the lexicon.
    # The duplicate of the lexicon contains duplicates of the lexical entries,
    # and the duplicate lexical entries contain duplicates of the underlying
    # forms but references to the very same morpheme objects.
    def dup
      return self.class.new(erc_list: erc_list.dup, lexicon: lexicon.dup, system: system)
    end

    # Returns a shallow copy of the grammar, with a reference to the very
    # same lexicon object.
    def dup_shallow
      return self.class.new(erc_list: erc_list.dup, lexicon: lexicon, system: system)
    end

    # Returns the underlying form for the given morpheme, as stored in
    # the grammar's lexicon. Returns nil if the morpheme does not appear
    # in the lexicon.
    # TODO: move this into the Lexicon class itself. Then have Grammar simply delegate.
    def get_uf(morph)
      lex_entry = @lexicon.find{|entry| entry.morpheme==morph} # get the lexical entry
      return nil if lex_entry.nil?
      return lex_entry.uf  # return the underlying form
    end

  end # class Grammar

end # module SL
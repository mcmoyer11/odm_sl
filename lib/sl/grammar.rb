# Author: Bruce Tesar
#

require_relative 'system'
require 'erc_list'
require 'lexicon'

module SL

  # A grammar for the SL linguistic system consists of a reference to
  # the SL::System linguistic system, a list of ERCs, and a lexicon.
  class Grammar
    # The optional label assigned to the grammar.
    attr_accessor :label
    
    # The list of ercs defining the ranking information of the grammar.
    attr_reader :erc_list
    
    # The lexicon for the grammar.
    attr_reader :lexicon

    # The linguistic system associated with this grammar.
    attr_reader :system

    # :call-seq:
    #   SL::Grammar.new() -> SL::Grammar
    #   SL::Grammar.new(erc_list: mylist, lexicon: mylexicon) -> SL::Grammar
    # 
    # The first form returns an empty grammar: an empty ERC list and an empty lexicon.
    # The second form returns a grammar with ERC list +mylist+ and lexicon +mylexicon+.
    #--
    # The default linguistic system is SL::System. The +system+ parameter is
    # primarily for testing purposes (dependency injection).
    def initialize(erc_list: nil, lexicon: Lexicon.new, system: System.instance)
      @system = system
      @erc_list = erc_list
      @erc_list ||= Erc_list.new(constraint_list: @system.constraints)
      self.label = "SL::Grammar"
      @lexicon = lexicon
    end

    # Adds an erc to the list.
    # Returns a reference to self (the grammar).
    def add_erc(erc)
      erc_list.add(erc)
      return self
    end

    # Returns true if the ERC list is currently consistent; false otherwise.
    def consistent?
      erc_list.consistent?
    end
  
    # Returns a deep copy of the grammar, with a duplicates of the lexicon.
    # The duplicate of the lexicon contains duplicates of the lexical entries,
    # and the duplicate lexical entries contain duplicates of the underlying
    # forms but references to the very same morpheme objects.
    def dup
      return self.class.new(erc_list: erc_list.dup, lexicon: lexicon.dup, system: system)
    end

    # Returns a copy of the grammar, with a copy of the ERC list, and
    # a reference to the very same lexicon object.
    def dup_same_lexicon
      return self.class.new(erc_list: erc_list.dup, lexicon: lexicon, system: system)
    end

    # Returns the underlying form for the given morpheme, as stored in
    # the grammar's lexicon. Returns nil if the morpheme does not appear
    # in the lexicon.
    def get_uf(morph)
      @lexicon.get_uf(morph)
    end
    
    # Parses the given output, returning the full word (with input,
    # correspondence). The input features match the lexicon for set features,
    # and are unset in the input for features unset in the lexicon.
    def parse_output(out)
      system.parse_output(out, lexicon)
    end
    
  end # class Grammar

end # module SL
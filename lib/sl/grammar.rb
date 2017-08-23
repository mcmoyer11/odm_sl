# Author: Bruce Tesar
#

require_relative 'system'
require 'lexicon'
require 'comparative_tableau'

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
      @erc_list ||= Comparative_tableau.new(constraint_list: @system.constraints, label: "")
      self.label = "SL::Grammar"
      @lexicon = lexicon
      @rcd_result = nil
    end

    # Adds an erc, and checks the consistency of the updated list.
    # Returns a reference to self (the grammar).
    #--
    # TODO: move this method to your erc_list class, and then delegate it from here.
    def add_erc(erc)
      erc_list << erc
      @rcd_result = nil # list changed, so old result is no longer valid
      return self
    end

    # Returns true if the ERC list is currently consistent; false otherwise.
    #--
    # TODO: delegate this to the erc_list class, once it has this functionality.
    def consistent?
      check_consistency if @rcd_result.nil?
      return @rcd_result.consistent?
    end
  
    # Checks to see if the ERC list is consistent by running RCD.
    # Returns true if the ERC list is consistent, false otherwise.
    # TODO: move this to the erc_list class.
    def check_consistency
      @rcd_result = Rcd.new(@erc_list)
      return @rcd_result.consistent?
    end
    private :check_consistency

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

    # TODO: standardize your .dup* conventions, and implement only those.
    def dup_same_lexicon
      return self.class.new(erc_list: erc_list.dup, lexicon: lexicon, system: system)
    end

    # Returns the underlying form for the given morpheme, as stored in
    # the grammar's lexicon. Returns nil if the morpheme does not appear
    # in the lexicon.
    def get_uf(morph)
      @lexicon.get_uf(morph)
    end
    
  end # class Grammar

end # module SL
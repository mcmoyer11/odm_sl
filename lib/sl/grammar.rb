# Author: Bruce Tesar
#

require_relative 'system'
require_relative '../lexicon'

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

    # Returns a new grammar.
    # The default initial ERC list and lexicon are empty.
    # The default linguistic system is SL::System.
    def initialize(erc_list: nil, lexicon: Lexicon.new, system: System.instance)
      @system = system
      @erc_list = erc_list
      # TODO: make label an optional parameter, even when constraints are provided?
      @erc_list ||= Comparative_tableau.new("", @system.constraints)
      self.label = "SL::Grammar"
      @lexicon = lexicon
      @rcd_result = nil
    end

    # Adds an erc, and checks the consistency of the updated list.
    # Returns true if the ercs are consistent, false otherwise.
    # TODO: move this method to your erc_list class, and then delegate it from here.
    def add_erc(erc)
      erc_list << erc
      check_consistency
    end

    # Returns true if the ERC list is currently consistent; false otherwise.
    def consistent?
      return @rcd_result.consistent? unless @rcd_result.nil?
      check_consistency
    end
  
    # Checks to see if the ERC list is consistent by running RCD.
    # Returns true if the ERC list is consistent, false otherwise.
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
    # TODO: move this into the Lexicon class itself. Then have Grammar simply delegate.
    def get_uf(morph)
      lex_entry = @lexicon.find{|entry| entry.morpheme==morph} # get the lexical entry
      return nil if lex_entry.nil?
      return lex_entry.uf  # return the underlying form
    end
    
    def to_s
      out_str += @lexicon.to_s + "\n"
      out_str += @erc_list.erc_list.join("\n")
      out_str
    end

  end # class Grammar

end # module SL
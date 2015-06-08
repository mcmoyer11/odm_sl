# Author: Crystal Akers, based on Bruce Tesar's sl/grammar
#

require_relative 'system'
require_relative '../lexicon'
require_relative '../rubot'
require 'rcd'
require 'comparative_tableau'

module SF

  # A grammar for the SF linguistic system consists of a reference to
  # the SF::System linguistic system, a constraint hierarchy, and a lexicon.
  class Grammar
    attr_accessor :hierarchy, :lexicon

    # Stores the linguistic system associated with this grammar.
    # In this case, the SF (stress-feet) linguistic system.
    @@system = System.instance

    # Returns a new grammar. If a hierarchy or a lexicon are not provided
    # as parameters, default initial values are used:
    # * the default initial lexicon is empty
    # * the default initial hierarchy results from applying RCD to an empty
    #   comparative tableau.
    def initialize(hier=default_initial_hierarchy, lex=default_initial_lexicon)
      @hierarchy = hier
      @lexicon = lex
    end

    # Returns a reference to the linguistic system associated with this grammar.
    def system
      @@system
    end

    # Returns a copy of the grammar, with duplicates of the hierarchy and
    # the lexicon.
    # The duplicate of the hierarchy contains references to the same constraint
    # objects, but duplicated strata.
    # The duplicate of the lexicon contains duplicates of the lexical entries,
    # and the duplicate lexical entries contain duplicates of the underlying
    # forms but references to the very same morpheme objects.
    def dup
      return self.class.new(@hierarchy.dup, @lexicon.dup)
    end

    # Returns a copy of the grammar, with a duplicate of the hierarchy, but
    # a reference to the very same lexicon object.
    # The duplicate of the hierarchy contains references to the same constraint
    # objects, but duplicated strata.
    def dup_hier_only
      return self.class.new(@hierarchy.dup, @lexicon)
    end

    # Returns the underlying form for the given morpheme, as stored in
    # the grammar's lexicon. Returns nil if the morpheme does not appear
    # in the lexicon.
    def get_uf(morph)
      lex_entry = @lexicon.find{|entry| entry.morpheme==morph} # get the lexical entry
      return nil if lex_entry.nil?
      return lex_entry.uf  # return the underlying form
    end

    private

    # The default initial hierarchy is the one resulting from applying RCD
    # to an empty comparative tableau.
    def default_initial_hierarchy
      Rcd.new(Comparative_tableau.new('empty',system.constraints)).hierarchy
    end

    # The default lexicon is simply a new (empty) lexicon.
    def default_initial_lexicon
      Lexicon.new
    end

  end # class Grammar

end # module SF
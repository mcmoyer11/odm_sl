# Author: Bruce Tesar
#

require_relative 'erc_list'
require_relative 'lexicon'

# A grammar consists of a reference to a linguistic system,
# a list of ERCs, and a lexicon.
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
  #   Grammar.new(system: mysystem) -> Grammar
  #   Grammar.new(system: mysystem, erc_list: mylist, lexicon: mylexicon) -> Grammar
  # 
  # The first form returns a grammar with an empty ERC list and an empty lexicon.
  # The second form returns a grammar with ERC list +mylist+ and lexicon +mylexicon+.
  #
  # The system parameter is mandatory.
  # Raises an exception if no system parameter is provided.
  def initialize(system: nil, erc_list: nil, lexicon: Lexicon.new)
    if system.nil? then
      raise "Grammar.new must be given a system parameter."
    end
    @system = system
    @erc_list = erc_list
    @erc_list ||= ErcList.new(constraint_list: @system.constraints)
    self.label = "Grammar"
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

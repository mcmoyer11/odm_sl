# Author: Bruce Tesar
#

require_relative 'rubot'
require 'rcd'
require 'comparative_tableau'

# A hypothesis contains a linguistic system reference, a grammar, and a
# list of supporting ercs.
class Hypothesis
  
  attr_reader :grammar, :erc_list

  # Creates a new hypothesis containing grammar _gram_. If no ERC list is
  # provided as a parameter, then a new Comparative_tableau is created
  # as an empty intial list.
  # Upon construction, consistency of the ERC list is immediately checked with
  # RCD. If the ERC list is consistent, the grammar's hierarchy is replaced by
  # the hierarchy constructed by RCD. If the ERC list is inconsistent, the
  # grammar's hierarchy is set to nil.
  def initialize(gram, erc_list=nil)
    @grammar = gram
    if erc_list.nil?
      @erc_list = Comparative_tableau.new("Hypothesis::@erc_list",
        gram.system.constraints)
    else
      @erc_list = erc_list
    end
    # Use RCD to check for consistency, and reset the hierarchy
    update_grammar
  end
  
  # Returns a copy of the hypothesis, with a duplicated grammar and erc list.
  # The linguistic system is assumed not to be subject to change, so the
  # reference is not altered.
  def dup
    hyp = Hypothesis.new(@grammar.dup,@erc_list.dup)
    return hyp
  end

  # Returns a copy of the hypothesis, with a duplicated erc list and hierarchy,
  # but a reference to the very same lexicon object. This is useful when you
  # want to test different candidates for consistency, but will not be
  # altering the lexicon in the process.
  def dup_same_lexicon
    return Hypothesis.new(@grammar.dup_hier_only, @erc_list.dup)
  end

  def system
    @grammar.system
  end

  # Returns the label of the hypothesis (equivalent to the ERC list
  # of the hypothesis).
  def label
    @erc_list.label
  end

  # Sets the label of the hypothesis to _new_lab_.
  def label=(new_lab)
    @erc_list.label = new_lab
  end

  # Returns true if the hypothesis is currently consistent; false otherwise.
  def consistent?
    return @consistent
  end
  
  # Adds an erc to the list, and updates the grammar.
  # An optional block provides the code for generating the updated
  # grammar (some variation of Rcd). If no block is provided, then
  # update_grammar is called with no block (resulting in the use of
  # regular RCD).
  def add_erc(erc)
    @erc_list << erc
    if block_given?
      update_grammar {|e| yield(e)}
    else
      update_grammar
    end
  end

  # Checks to see if the ercs are consistent, and updates the constraint
  # hierarchy in the grammar.
  # An optional block provides the code for generating the updated
  # grammar (some variation of Rcd). If no block is provided, then
  # regular RCD is used (all constraints has high as possible).
  def update_grammar
    if block_given?
      rcd_result = yield(@erc_list)
    else
      rcd_result = Rcd.new(@erc_list)
    end
    @consistent = rcd_result.consistent?
    if @consistent then
      @grammar.hierarchy = rcd_result.hierarchy
    else
      @grammar.hierarchy = nil
    end
    return rcd_result
  end

  # Returns a string containing string representations of
  # the hierarchy, the lexicon, and the ERC list of this hypothesis.
  def to_s
    out_str = @grammar.hierarchy.to_s + "\n"
    out_str += @grammar.lexicon.to_s + "\n"
    out_str += @erc_list.join("\n")
    out_str
  end
  
end # class Hypothesis

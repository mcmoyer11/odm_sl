# Author: Bruce Tesar
#

require_relative 'rcd'
require_relative 'comparative_tableau'

# A hypothesis contains a linguistic system reference, a grammar, and a
# list of supporting ercs.
class Hypothesis
  # The grammar object for the hypothesis
  attr_reader :grammar
  
  # The list of ERCs included in this hypothesis
  attr_reader :erc_list

  # Creates a new hypothesis containing grammar _gram_. If no ERC list is
  # provided as a parameter, then a new Comparative_tableau is created
  # as an empty initial list.
  # Upon construction, consistency of the ERC list is immediately checked with
  # RCD.
  def initialize(gram, erc_list=nil)
    @grammar = gram
    if erc_list.nil?
      @erc_list = Comparative_tableau.new("Hypothesis::@erc_list",
        gram.system.constraints)
    else
      @erc_list = erc_list
    end
    # check the erc list for consistency
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

  # Returns a reference to the linguistic system underlying the grammar.
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
  
  # Adds an erc, and checks the consistency of the updated list.
  # Returns the Rcd object used to determine consistency.
  def add_erc(erc)
    @erc_list << erc
    update_grammar
  end

  # Checks to see if the ercs are consistent.
  # Returns the Rcd object used to determine consistency.
  def update_grammar
    rcd_result = Rcd.new(@erc_list)
    @consistent = rcd_result.consistent?
    return rcd_result
  end
  private :update_grammar

  # Returns a string containing string representations of
  # the lexicon and the ERC list of this hypothesis.
  def to_s
    out_str += @grammar.lexicon.to_s + "\n"
    out_str += @erc_list.join("\n")
    out_str
  end
  
end # class Hypothesis

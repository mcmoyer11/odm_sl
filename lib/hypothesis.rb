# Author: Bruce Tesar
#

require_relative 'rcd'
require_relative 'comparative_tableau'

# A hypothesis contains a grammar and a list of supporting ercs.
# The grammar is presumed to contain a lexicon and a reference to
# the linguistic system in use.
class Hypothesis
  # The grammar object for the hypothesis
  attr_reader :grammar
  
  # The list of ERCs included in this hypothesis
  attr_reader :erc_list
  
  # The label for this hypothesis
  attr_accessor :label

  # Creates a new hypothesis containing grammar _gram_. If no ERC list is
  # provided as a parameter, then a new Comparative_tableau is created
  # as an empty initial list. If an _erc_list_ is provided, its contents
  # are copied into a new ERC list specific to this hypothesis.
  # Upon construction, consistency of the ERC list is immediately checked with
  # RCD.
  def initialize(gram, erc_list=nil)
    @grammar = gram
    @label = "Hypothesis"
    @erc_list = Comparative_tableau.new(@label, @grammar.system.constraints)
    unless erc_list.nil?
      erc_list.each {|erc| @erc_list << erc}
      @label = erc_list.label
    end
    # check the erc list for consistency (initializing @rcd_result)
    check_consistency
  end
  
  # Returns a copy of the hypothesis, with a duplicated grammar and erc list.
  # The linguistic system is assumed not to be subject to change, so the
  # reference is not altered.
  def dup
    hyp = Hypothesis.new(@grammar.dup,@erc_list)
    hyp.label = label
    return hyp
  end

  # Returns a copy of the hypothesis, with a duplicated erc list,
  # but a reference to the very same lexicon object. This is useful when you
  # want to test different candidates for consistency, but will not be
  # altering the lexicon in the process.
  def dup_same_lexicon
    hyp = Hypothesis.new(@grammar.dup_shallow, @erc_list)
    hyp.label = label
    return hyp
  end

  # Returns a reference to the linguistic system underlying the grammar.
  def system
    @grammar.system
  end

  # Returns true if the hypothesis is currently consistent; false otherwise.
  def consistent?
    return @rcd_result.consistent?
  end
  
  # Adds an erc, and checks the consistency of the updated list.
  # Returns true if the ercs are consistent, false otherwise.
  def add_erc(erc)
    @erc_list << erc
    check_consistency
  end

  # Checks to see if the ercs are consistent.
  # Returns true if the ercs are consistent, false otherwise.
  def check_consistency
    @rcd_result = Rcd.new(@erc_list)
    return consistent?
  end
  private :check_consistency

  # Returns a string containing string representations of
  # the lexicon and the ERC list of this hypothesis.
  def to_s
    out_str += @grammar.lexicon.to_s + "\n"
    out_str += @erc_list.join("\n")
    out_str
  end
  
end # class Hypothesis

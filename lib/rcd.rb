# Author: Bruce Tesar
# 

require_relative 'hierarchy'

# Implements Recursive Constraint Demotion (RCD).
# An Rcd object takes a comparative tableau, runs RCD, and stores the
# constructed hierarchy along with a flag indicating consistency.
#
# In the case of inconsistency, unranked constraints and the remaining
# inconsistent ercs are also stored. The stored hierarchy contains the
# rankable constraints as ranked by RCD, but not the unrankable constraints.
#
# References:
#
# Tesar 1995. {Computational Optimality Theory.}[http://roa.rutgers.edu/view.php3?id=548]
#
# Tesar 1997. {Multi-Recursive Constraint Demotion.}[http://roa.rutgers.edu/view.php3?id=209]
#
# Tesar & Smolensky 2000. <em>Learnability in Optimality Theory</em>. MIT Press.
class Rcd

  # Returns an object containing the results of running Recursive
  # Constraint Demotion on the ERCs of comparative tableau +ct+.
  # Accepts an optional label; the default label is "Rcd".
  #--
  # The constructor copies the ERCs of the ct parameter to the internal
  # array @erc_list.
  # Thus, it shouldn't matter if the ct pointed to by the parameter
  # subsequently changes state, so long as the constraint list
  # and erc objects are not themselves directly altered.
  def initialize(ct, label: "Rcd")
    @erc_list = []
    ct.each {|erc| @erc_list << erc}
    @label = label
    @constraints = ct.constraint_list
    run_rcd
  end

  # Returns the label of the comparative tableau that RCD was applied to.
  def label
    @label
  end

  # Returns a list of the constraints.
  def constraint_list
    @constraints
  end

  # Returns the constraint hierarchy constructed by RCD.
  def hierarchy
    return @hierarchy
  end

  # Returns true if the set of ERCs is consistent; returns false otherwise.
  def consistent?
    return @consistent
  end

  # Returns an array of constraints that remain unranked after the
  # completion of RCD. This list will be empty unless the set of ERCs
  # is inconsistent.
  def unranked
    return @unranked
  end

  # Returns a comparative tableau of unexplained ercs.
  # When the original set of ercs is consistent, this tableau
  # will either be empty or contain only trivial ercs (all e).
  def unex_ercs
    @unex_ercs
  end

  # Returns a "stratified" list of explained ercs, as an array of arrays.
  # The first "stratum" contains the ercs explained by the constraints in
  # the first stratum of the constraint hierarchy, and so forth.
  def ex_ercs
    @ex_ercs
  end

private  # The methods below are private.

  # A constraint is rankable with respect to a set of ercs if the constraint
  # does not prefer the loser in any of the ercs.
  def rankable?(con, ercs)
    not ercs.any? {|erc| erc.l?(con)}
  end
  
  # An erc is explained with respect to a set of constraints if at least
  # one of the constraints prefers the winner.
  def explained?(erc, constraints)
    constraints.any? {|con| erc.w?(con)}
  end

  # Executes Recursive Constraint Demotion (RCD) on the list of ercs.
  # If the tableau is consistent, @consistent will be true, @hierarchy will
  # contain the computed hierarchy, and @unranked and @unex_ercs will be empty.
  # At the end, @unranked will contain any unrankable constraints, and
  # @unex_ercs will contain any unexplainable, collectively inconsistent ercs.
  # @ex_ercs will contain a "stratified" representation of the explained ercs:
  # The first stratum will contain the ercs explained by the constraints in
  # the first stratum, and so forth.
  def run_rcd
    # Initialize the instance variables that are computed/altered within run_rcd.
    # Initially, all ercs are unexplained and all constraints are unranked.
    @consistent = true # innocent until proven guilty
    @hierarchy = Hierarchy.new
    @unex_ercs = @erc_list
    @ex_ercs = []
    @unranked = @constraints
    
    # Find the initially rankable constraints
    rankable, @unranked = @unranked.partition{|con| rankable?(con, @unex_ercs)}
    while !rankable.empty? # repeat until no more constraints are rankable
      stratum = choose_cons_to_rank(rankable)
      @unranked.concat(rankable - stratum)
      @hierarchy << stratum # put the current stratum in the hierarchy
      # Move the ercs explained by the current stratum
      explained, @unex_ercs = @unex_ercs.partition{|e| explained?(e, stratum)}
      @ex_ercs << explained # store the explained ercs as the next "erc stratum"
      # Put the newly rankable constraints into the next constraint stratum
      rankable, @unranked = @unranked.partition{|con| rankable?(con, @unex_ercs)}    
    end
    # If unranked constraints remain, then the ercs are inconsistent.
    @consistent = false unless @unranked.empty?
  end
  
  # This method defines the ranking bias. The default here is to rank all
  # constraints as high as possible, as per original RCD. This method can
  # be overridden in subclasses to define other biases (like faithfulness
  # as low as possible, as in BCD).
  # It is given an array of rankable constraints, and returns an array of
  # constraints to actually be placed into the hierarchy.
  def choose_cons_to_rank(rankable)
    return rankable
  end
  
end # class Rcd

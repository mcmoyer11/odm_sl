# Author: Bruce Tesar

require_relative 'hierarchy'

# Implements Recursive Constraint Demotion (RCD).
# An Rcd object takes a list of ERCs, runs RCD, and stores the
# constructed hierarchy along with a flag indicating consistency.
#
# In the case of inconsistency, unranked constraints and the remaining
# inconsistent ERCs are also stored. The stored hierarchy contains the
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
  # Constraint Demotion on the ERC list +erc_list+.
  # Accepts an optional label; the default label is "RCD".
  #--
  # The constructor copies the ERCs of the +erc_list+ parameter to the internal
  # array +@ercs+. Thus, it shouldn't matter if the parameter list
  # subsequently changes state, so long as the constraint list
  # and ERC objects are not themselves directly altered.
  def initialize(erc_list, label: "RCD")
    @ercs = []
    erc_list.each {|erc| @ercs << erc}
    @label = label
    @constraints = erc_list.constraint_list
    run_rcd
  end

  # Returns the label
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

  # Returns a list of unexplained ERCs, as an array.
  # When the original list of ERCs is consistent, this array
  # will either be empty or contain only trivial ERCs (all e).
  def unex_ercs
    @unex_ercs
  end

  # Returns a "stratified" list of explained ERCs, as an array of arrays.
  # The first "stratum" contains the ERCs explained by the constraints in
  # the first stratum of the constraint hierarchy, and so forth.
  def ex_ercs
    @ex_ercs
  end

private  # The methods below are private.

  # A constraint is rankable with respect to a set of ERCs if the constraint
  # does not prefer the loser in any of the ERCs.
  def rankable?(con, ercs)
    not ercs.any? {|erc| erc.l?(con)}
  end
  
  # An ERC is explained with respect to a set of constraints if at least
  # one of the constraints prefers the winner.
  def explained?(erc, constraints)
    constraints.any? {|con| erc.w?(con)}
  end

  # Executes Recursive Constraint Demotion (RCD) on the list of ERCs.
  # If the ERCs are consistent, @consistent will be true, @hierarchy will
  # contain the computed hierarchy, and @unranked and @unex_ercs will be empty.
  # At the end, @unranked will contain any unrankable constraints, and
  # @unex_ercs will contain any unexplainable, collectively inconsistent ERCs.
  # @ex_ercs will contain a "stratified" representation of the explained ERCs:
  # The first stratum will contain the ERCs explained by the constraints in
  # the first stratum, and so forth.
  def run_rcd
    # Initialize the instance variables that are computed/altered within run_rcd.
    # Initially, all ERCs are unexplained and all constraints are unranked.
    @consistent = true # innocent until proven guilty
    @hierarchy = Hierarchy.new
    @unex_ercs = @ercs
    @ex_ercs = []
    @unranked = @constraints
    
    # Find the initially rankable constraints
    rankable, @unranked = @unranked.partition{|con| rankable?(con, @unex_ercs)}
    while !rankable.empty? # repeat until no more constraints are rankable
      stratum = choose_cons_to_rank(rankable)
      @unranked.concat(rankable - stratum)
      @hierarchy << stratum # put the current stratum in the hierarchy
      # Move the ERCs explained by the current stratum
      explained, @unex_ercs = @unex_ercs.partition{|e| explained?(e, stratum)}
      @ex_ercs << explained # store the explained ERCs as the next "erc stratum"
      # Put the newly rankable constraints into the next constraint stratum
      rankable, @unranked = @unranked.partition{|con| rankable?(con, @unex_ercs)}    
    end
    # If unranked constraints remain, then the ERCs are inconsistent.
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

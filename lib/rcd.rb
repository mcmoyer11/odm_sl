# Author: Bruce Tesar

require_relative 'hierarchy'

# Implements Recursive Constraint Demotion (RCD).
# An Rcd object takes a list of ERCs, runs RCD, and stores the
# constructed hierarchy along with a flag indicating consistency.
#
# In the case of inconsistency, the unranked constraints and the remaining
# unexplained ERCs are also stored. The stored hierarchy contains the
# rankable constraints as ranked by RCD, with the unrankable constraints in
# an added bottom stratum.
#
# ===References
#
# Tesar 1995. Computational Optimality Theory. ROA-90.
#
# Tesar 1997. Multi-Recursive Constraint Demotion. ROA-197.
#
# Tesar & Smolensky 2000. <em>Learnability in Optimality Theory</em>. MIT Press.
class Rcd

  # Returns an object containing the results of running Recursive
  # Constraint Demotion on the ERC list +erc_list+.
  # Accepts an optional label; the default label is "RCD".
  #--
  # The constructor copies the ERCs of the +erc_list+ parameter to the internal
  # array @ercs. Thus, it shouldn't matter if the parameter list
  # subsequently changes state, so long as the constraint list
  # and ERC objects are not themselves directly altered.
  #++ 
  # :call-seq:
  #   Rcd.new(erc_list) -> rcd
  #   Rcd.new(erc_list, label: my_label) -> rcd
  def initialize(erc_list, label: "RCD")
    @ercs = [] # an array, no matter the class of erc_list
    erc_list.each {|erc| @ercs << erc}
    @label = label
    @constraints = erc_list.constraint_list
    run_rcd
  end

  # Returns a list of all the ERCs, as an ErcList object.
  def erc_list
    new_erc_list = ErcList.new
    new_erc_list.add_all(@ercs)
    return new_erc_list
  end
  
  # Returns the label
  def label
    @label
  end

  # Returns a list of the constraints.
  def constraint_list
    @constraints
  end

  # Returns true if the set of ERCs is consistent; returns false otherwise.
  def consistent?
    return @consistent
  end

  # Returns a full constraint hierarchy. If the ERCs are inconsistent,
  # Then the hierarchy has the ranked constraints constructed by RCD, with
  # the unranked constraints added as a bottom stratum.
  def hierarchy
    hierarchy = @ranked.dup
    # Add any unranked constraints as a bottom stratum
    (hierarchy << unranked) unless unranked.empty?
    return hierarchy
  end
  
  # Returns the hierarchy of constraints ranked by RCD. If the set of
  # ERCs is inconsistent, this will not include all of the constraints;
  # the rest of the constraints will be returned by #unranked().
  def ranked
    return @ranked
  end

  # Returns an array of constraints that remain unranked after the
  # completion of RCD. This list will be empty unless the set of ERCs
  # is inconsistent.
  def unranked
    return @unranked
  end

  # Returns a "stratified" list of explained ERCs, as an array of arrays.
  # The first "stratum" contains the ERCs explained by the constraints in
  # the first stratum of the constraint hierarchy, and so forth.
  def ex_ercs
    @ex_ercs
  end

  # Returns a list of unexplained ERCs, as an array.
  # When the original list of ERCs is consistent, this array
  # will either be empty or contain only trivial ERCs (all e).
  def unex_ercs
    @unex_ercs
  end

  # A constraint is rankable with respect to a set of ERCs if the constraint
  # does not prefer the loser in any of the ERCs.
  #
  # :call-seq:
  #   rankable?(constraint, erc_list) -> boolean
  def rankable?(con, ercs)
    not ercs.any? {|erc| erc.l?(con)}
  end
  protected :rankable?
  
  # An ERC is explained with respect to a set of constraints if at least
  # one of the constraints prefers the winner.
  #
  # :call-seq:
  #   explained?(erc, constraint_list) -> boolean
  def explained?(erc, constraints)
    constraints.any? {|con| erc.w?(con)}
  end
  protected :explained?

  # Executes Recursive Constraint Demotion (RCD) on the list of ERCs.
  # If the ERCs are consistent, @consistent will be true, @ranked will
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
    @ranked = Hierarchy.new
    @unex_ercs = @ercs
    @ex_ercs = []
    @unranked = constraint_list
    # Find the initially rankable constraints
    rankable, @unranked = @unranked.partition{|con| rankable?(con, @unex_ercs)}
    until rankable.empty? # repeat until no more constraints are rankable
      stratum = choose_cons_to_rank(rankable)
      @unranked.concat(rankable - stratum)
      @ranked << stratum # put the current stratum in the hierarchy
      # Move the ERCs explained by the current stratum
      explained, @unex_ercs = @unex_ercs.partition{|e| explained?(e, stratum)}
      @ex_ercs << explained # store the explained ERCs as the next "erc stratum"
      # Find newly rankable constraints
      rankable, @unranked = @unranked.partition{|con| rankable?(con, @unex_ercs)}    
    end
    # If unranked constraints remain, then the ERCs are inconsistent.
    @consistent = false unless @unranked.empty?
  end
  protected :run_rcd
  
  # This method defines the ranking bias. The default here is to rank all
  # constraints as high as possible, as per original RCD. This method can
  # be overridden in subclasses to define other biases (like faithfulness
  # as low as possible, as in BCD).
  # It is given an array of rankable constraints, and returns an array of
  # constraints to actually be placed into the hierarchy.
  #
  # :call-seq:
  #   choose_cons_to_rank(rankable_constraint_list) -> array
  def choose_cons_to_rank(rankable)
    return rankable
  end
  protected :choose_cons_to_rank
  
end # class Rcd

# Author: Bruce Tesar
# 

# Represents a "cover" of a set of ercs by a set of constraints assigning
# W to one or more of the ercs. The set of ercs must all be assigned L by
# the same, single constraint, accessible via #l_constraint(). A cover
# is built up one W-constraint at a time, via #add_w_con(), and calculates
# the reduced ercs that constitute the covering ercs of the cover, and
# "ranking" ercs, which are used to enforce consistency between different
# covers (for different L-constraints) when they are combined.
class W_cover
  def initialize()
    @covered_ercs = Hash.new # map each W-constraint to the Ercs it accounts for.
    @reduced_ercs = []
    @ranking_ercs = []
    @l_con = nil
    @constraint_list = nil
  end

  # Returns the single constraint assigning L to all of the covered ercs.
  # This method raises a _RuntimeError_ if no ercs have yet been covered,
  # because the cover cannot determine which constraint assigns the L.
  def l_constraint()
    raise RuntimeError if @covered_ercs.empty?
    @l_con ||= @covered_ercs[w_constraints[0]][0].l_cons.first
  end

  # Returns the W-constraints that are the basis for the cover; they
  # collectively assign W to all of the ercs being covered.
  def w_constraints()
    @covered_ercs.keys
  end

  # Returns a list of the constraints in use.
  # This method raises a _RuntimeError_ if no ercs have yet been covered,
  # because the cover cannot determine what the constraints are.
  def constraint_list()
    raise RuntimeError if @covered_ercs.empty?
    @constraint_list ||= @covered_ercs[w_constraints[0]][0].constraint_list
  end

  # Returns the ercs constituting the erc cover. Each reduced erc is assigned
  # L by the L-constraint, and a single W by one of the W-constraints; there
  # is exactly one such erc in the list for each W-constraint of the cover.
  def reduced_ercs()
    @reduced_ercs
  end

  # Returns an array of "ranking ercs", which are not part of the cover at
  # all, but are used to enforce a kind of consistency between covers for
  # different L-constraints, when they are combined.
  # 
  # When a W-constraint is added to a cover, it is assumed to conceptually
  # be ranked above the other constraints that assign W to any of the ercs
  # covered by the W-constraint. Those conceptual ranking relations are
  # represented with ranking ercs. The goal is to cut down on redundancy
  # due to ordering, so that a cover constructed by adding W-constraint C1
  # first, and then C2, is not kept distinct from a cover constructed by
  # adding C2 first, and then C1.
  def ranking_ercs()
    @ranking_ercs
  end
  
  # Returns a duplicate cover object, in which the lists of ercs
  # (covered_ercs, reduced_ercs, ranking_ercs) have themselves been
  # duplicated, so adding to one of the lists in the duplicate will
  # not alter the original (and vice-versa).
  def dup
    copy = W_cover.new
    copy.instance_variable_set(:@covered_ercs, @covered_ercs.dup)
    copy.instance_variable_set(:@reduced_ercs, @reduced_ercs.dup)
    copy.instance_variable_set(:@ranking_ercs, @ranking_ercs.dup)
    return copy
  end

  def add_w_con(w_con, covered_ercs)
    # store the ercs covered by _w_con_
    @covered_ercs[w_con] = covered_ercs
    # add a reduced erc for _w_con_
    newerc = Erc.new(constraint_list)
    newerc.set_l(l_constraint)
    newerc.set_w(w_con)
    @reduced_ercs << newerc
    # add ranking ercs for the other W-constraints active in
    # the newly covered ercs
    active_w_cons = find_active_w_cons(covered_ercs)
    active_w_cons.reject! {|con|  con == w_con} # remove the added w-constraint itself
    active_w_cons.each do |active_con|
      newerc = Erc.new(constraint_list)
      newerc.set_l(active_con)
      newerc.set_w(w_con)
      @ranking_ercs << newerc
    end
  end

  #--
  # Returns a list of W-constraints that are "active" in _ercs_,
  # meaning that they assign a W to at least one of the ercs in _ercs_.
  def find_active_w_cons(ercs)
    active = []
    constraint_list.each do |wc|
      active << wc if ercs.find{|e| e.w?(wc)}
    end
    return active
  end
  private :find_active_w_cons

end

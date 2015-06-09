# Author: Bruce Tesar
#

require_relative 'w_cover'
require_relative 'comparative_tableau'
require_relative 'rcd'
require_relative 'fred'
#require 'facets/array/product'

# Takes, as input, a skeletal basis, and expands it into a set of
# derived bases that is collectively equivalent to the original basis
# (i.e., admits exactly the same total rankings), such that each
# derived basis constitutes a partial order.
class Skb_expansion
  def initialize(orig_skb)
    @orig_skb = orig_skb
    @conj_exp = Erc.conj_expand_list(@orig_skb)
    find_covers_for_each_l_constraint
    combine_covers_across_l_constraints
    eliminate_lingering_transitive_redundancy
  end

  def original_skb() @orig_skb end
  def conj_expansion() @conj_exp end
  def cover_groups() @cover_groups end

  # Returns an array of diagram bases. Each basis is in the form of
  # a Comparative_tableau.
  def diagram_bases() @diagram_bases end

  def constraint_list
    return [] if @orig_skb.empty?
    @constraint_list ||= @orig_skb[0].constraint_list
  end

  def find_covers_for_each_l_constraint
    @cover_groups = []
    ercs_by_l = @conj_exp.group_by{|erc| erc.l_cons.first}
    ercs_by_l.each do |l_con, erc_group|
      # find the covers within the erc group
      covers = find_covers(erc_group)
      # add the group of covers for l_con to the hash
      @cover_groups << covers
    end
  end

  # Given a list of ercs, each with the same single L-constraint,
  # returns a list of W-constraint covers.
  def find_covers(ercs)
    # find W-assigning constraints, and sort by # W's
    w_sorted = count_and_sort_w(ercs,constraint_list)
    # binary branch-and-bound over sorted W-cons, to find covers
    covers = check_possible_w_covers(W_cover.new, ercs, w_sorted, [])
    #return the covers
    return covers
  end

  # Counts the number of members of _ercs_ that are assigned a W by each
  # constraint in _constraints_. It then sorts a list of W-assigning constraints
  # by the number of W's assigned (descending), and then by constraint name
  # (ascending).
  # It returns the sorted list of W-assigning constraints.
  def count_and_sort_w(ercs, constraints)
    return [] if ercs.empty?
    # Find the W constraints
    w_cons = constraints.find_all{|con| ercs.detect{|erc| erc.w?(con)}}
    # Count the number of W's assigned by each w-constraint.
    w_count = Hash.new
    w_cons.each do |con|
      w_count[con] = ercs.count{|erc| erc.w?(con)}
    end
    # Sort hash entries by value (descending), and then by constraint name (ascending)
    w_count_sorted = w_count.sort_by{|pair| [-pair[1],pair[0].to_s]}
    # Return a list of just the w-constraints, in sorted order.
    return w_count_sorted.map{|pair| pair[0]}
  end

  # Recursively checks for possible W-constraint covers for _uncovered_ercs_.
  # The W-constraint covers include the constraints in _cur_cover_, and
  # additional constraints may be selected from _w_cons_. Any successful
  # covers that are found are added to the list _covers_, which is returned
  # at the end.
  #--
  # If a W-constraint is added to the current cover, the ercs that the
  # constraint assigns W to are removed. The remaining uncovered ercs
  # are then checked, and a new set of W-assigning ercs is generated
  # and sorted by number of W's assigned. The sorting by number of occurrences
  # is a cheap stand-in for detecting when one constraint assigns W's to
  # a superset of the ercs assigned W by another constraint. If one is going
  # to include the superset constraint in the cover, there is no point in
  # having the subset constraint in the cover, and the sorting eliminates
  # such cases.
  #++
  def check_possible_w_covers(current_cover, uncovered_ercs, w_cons, covers)
    # if no uncovered ercs remain, then a cover is complete
    if uncovered_ercs.empty? then
      covers << current_cover.dup
      return covers
    end
    # if no w-constraints remain, the current cover fails
    return covers if w_cons.empty?
    # Remove the next remaining w-constraint from the list
    w_remaining = w_cons.dup
    next_con = w_remaining.shift
    # Try adding the next constraint to the current cover.
    # If the next constraint doesn't cover any ercs, skip it.
    newly_covered_ercs, still_uncovered_ercs = uncovered_ercs.partition{|erc| erc.w?(next_con)}
    unless newly_covered_ercs.empty? then
      updated_cover = current_cover.dup
      updated_cover.add_w_con(next_con,newly_covered_ercs)
      # Check for constraints still assigning W's, and sort by # W's
      new_w_remaining = count_and_sort_w(still_uncovered_ercs, w_remaining)
      covers = check_possible_w_covers(updated_cover, still_uncovered_ercs,
        new_w_remaining, covers)
    end
    # Try omitting the next constraint from the current cover
    covers = check_possible_w_covers(current_cover, uncovered_ercs,
      w_remaining, covers)
    return covers
  end

  def combine_covers_across_l_constraints
    @cart_prod = [[]] # default, in case no covers are needed.
    # take the cartesian product of the groups of covers.
    unless @cover_groups.empty?
      @cart_prod = @cover_groups[0].product(*@cover_groups[1..-1])
    end
    # Convert each n-tuple of the cart. prod. to a set of ercs, and
    # keep those sets that are consistent as diagram bases.
    @diagram_bases = []
    @cart_prod.each do |w_cover_list|
      # concatenate the cover ercs (and ranking ercs) across the covers of
      # the L-constraints.
      cover_ercs = w_cover_list.inject([]){|all, cov| all.concat(cov.reduced_ercs)}
      ranking_ercs = w_cover_list.inject([]){|all, cov| all.concat(cov.ranking_ercs)}
      # Test to see if the combined cover and ranking ercs are consistent.
      comb_ercs = Comparative_tableau.new("Consistency test for cover", constraint_list)
      comb_ercs.concat(cover_ercs).concat(ranking_ercs)
      if Rcd.new(comb_ercs).consistent? then
        @diagram_bases << cover_ercs  # keep the cover ercs for the consistent ones
      end
    end
    # Convert each diagram basis from an array to a Comparative_tableau
    @diagram_bases = @diagram_bases.map{|b| Comparative_tableau.new.concat(b)}
  end
  
  def eliminate_lingering_transitive_redundancy
    @diagram_bases = @diagram_bases.map{|basis| Fred.new(basis).skb}
  end

end # class Skb_expansion

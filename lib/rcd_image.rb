# Author: Bruce Tesar
# 

require_relative "comparative_tableau_image"
require_relative "sheet"
require_relative "hierarchy"

# An RCD_image object represents the results of applying RCD to
# a list of ERCs.
class RCD_image

  # The RCD results object
  attr_reader :rcd_result

  # Constructs a new RCD_image from an rcd_results object.
  # 
  # +rcd_result+ - the result of an RCD execution (e.g., class Rcd).
  def initialize(rcd_result,
    comp_tableau_image_class: ComparativeTableauImage)
    @rcd_result = rcd_result
    @comp_tableau_image_class = comp_tableau_image_class
    ercs, constraints = construct_ercs_and_constraints
    # TODO: add Erc_list#each_with_index, instead of calling ercs.to_a
    @comp_tableau_image = @comp_tableau_image_class.new(ercs.to_a, constraints)
    @sheet = Sheet.new
    construct_image
  end

  # Returns the sheet object underlying the RCD image.
  def sheet
    @sheet
  end
  
  # Delegate all method calls not explicitly defined here to the sheet object.
  def method_missing(name, *args)
    @sheet.send(name, *args)
  end
  protected :method_missing
  
  # Constructs, from the RCD result, flat lists of the constraints and the ERCs,
  # sorted in the order in which they will appear in the tableau.
  #
  # :call-seq:
  #   construct_ercs_and_constraints() -> [sorted_ercs, sorted_constraints]
  def construct_ercs_and_constraints
    # Add the unranked constraints as a "final stratum" to the hierarchy.
    hier_with_unranked = Hierarchy.new
    hier_with_unranked.concat(rcd_result.hierarchy)
    hier_with_unranked << rcd_result.unranked unless rcd_result.unranked.empty?
    # Create a flat list of the constraints in sorted order
    sorted_cons = hier_with_unranked.flatten
    # sort the ercs with respect to the RCD constraint hierarchy
    sorted_ercs, ercs_by_stratum, explained_ercs = sort_rcd_results(rcd_result)
    return sorted_ercs, sorted_cons
  end
  protected :construct_ercs_and_constraints

  # Build the image from its main part, the comparative tableau image.
  def construct_image
    @sheet.put_range[1,1] = @comp_tableau_image
  end
  protected :construct_image
  
  # Sort the ercs of an RCD result in several ways.
  #
  # :call-seq:
  #   sort_rcd_results(rcd_result) -> [sorted_ercs, ercs_by_stratum, explained_ercs]
  #
  # The returned array contains three objects, each a list of ercs.
  # sorted_ercs:: all of the ercs in a flat array, sorted with respect to the
  #               constraint hierarchy constructed by RCD.
  # ercs_by_stratum:: all of the ercs in an array of strata, with each
  #                   stratum corresponding to a stratum of the hierarchy
  #                   constructed by RCD. The first erc stratum contains those
  #                   ercs assigned a W by a constraint in the first stratum
  #                   of the hierarchy, and so forth.
  # explained_ercs:: only the explained ercs (those that are properly accounted
  #                  for by RCD), in a flat array, sorted with respect to the
  #                  constraint hierarchy constructed by RCD.
  def sort_rcd_results(rcd_result)
    # Sort each "stratum" of ercs by the order of the constraints in the
    # corresponding constraint hierarchy stratum, so that the ercs assigned
    # a W by the first constraint in the stratum appear first, etc.
    flat_hier = rcd_result.hierarchy.flatten
    flat_hier.concat(rcd_result.unranked) unless rcd_result.unranked.empty?
    ercs_by_stratum = []
    rcd_result.ex_ercs.each do |ercs|
      ercs_by_stratum << sort_by_constraint_order(ercs,flat_hier)
    end
    explained_ercs = ercs_by_stratum.flatten # in sorted order

    # add any unexplained ercs as the last level of the stratified erc list.
    unex_ercs = []
    unless rcd_result.unex_ercs.empty? then
      unex_ercs =
        sort_by_constraint_order(rcd_result.unex_ercs, flat_hier)
      ercs_by_stratum << unex_ercs
    end

    # create a list of the ercs in sorted order
    sorted_ercs = Erc_list.new
    sorted_ercs.add_all(explained_ercs)
    sorted_ercs.add_all(unex_ercs)

    return sorted_ercs, ercs_by_stratum, explained_ercs
  end
  protected :sort_rcd_results

  # Takes a list of ercs and sorts them with respect to a list of constraints,
  # such that all ercs assigned a W by the first constraint occur first in
  # the sorted erc list, followed by all the ercs assigned a W by the second
  # constraint (but not the first), and so forth. Ercs that are not assigned
  # a W by any of the constraints in the list occur last.
  #
  # This is used for display purposes, to create a clean "W boundary" in
  # formatted comparative tableaux.
  #
  # :call-seq:
  #   sort_by_constraint_order(erc_list, constraint_list) -> array
  def sort_by_constraint_order(ercs,cons)
    return ercs if ercs.empty? or cons.empty?
    con_list = cons.dup
    con = con_list.shift
    w_ercs, no_w_ercs = ercs.partition{|e| e.w?(con)}
    l_ercs, e_ercs = no_w_ercs.partition{|e| e.l?(con)}
    sorted_ercs = []
    sorted_ercs.concat(sort_by_constraint_order(w_ercs, con_list))
    sorted_ercs.concat(sort_by_constraint_order(e_ercs, con_list))
    sorted_ercs.concat(sort_by_constraint_order(l_ercs, con_list))
    return sorted_ercs
  end
  protected :sort_by_constraint_order

end # class RCD_image

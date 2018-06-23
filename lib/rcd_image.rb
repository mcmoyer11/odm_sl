# Author: Bruce Tesar
# 

require_relative "ercs_image"
require_relative "ct_image"
require_relative "hierarchy"

# An RCD_image object represents the results of applying RCD to
# a list of ERCs.
#
# It is derived from CT_image, which represents a basic CT, and adds
# elements relevant to representing RCD results in CT form.
class RCD_image < CT_image

  # The RCD results object
  attr_reader :rcd_result

  # Constructs a new RCD_image from an rcd_results object.
  # 
  # +rcd_result+ - the result of an RCD execution (e.g., class Rcd).
  def initialize(rcd_result)
    @rcd_result = rcd_result
    ercs, constraints = construct_ercs_and_constraints
    super({:ercs=>ercs,:constraints=>constraints})
  end

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
      ercs_by_stratum << ERCs_image.sort_by_constraint_order(ercs,flat_hier)
    end
    explained_ercs = ercs_by_stratum.flatten # in sorted order

    # add any unexplained ercs as the last level of the stratified erc list.
    unex_ercs = []
    unless rcd_result.unex_ercs.empty? then
      unex_ercs =
        ERCs_image.sort_by_constraint_order(rcd_result.unex_ercs, flat_hier)
      ercs_by_stratum << unex_ercs
    end

    # create a list of the ercs in sorted order
    sorted_ercs = Erc_list.new
    sorted_ercs.add_all(explained_ercs)
    sorted_ercs.add_all(unex_ercs)

    return sorted_ercs, ercs_by_stratum, explained_ercs
  end

end # class RCD_image

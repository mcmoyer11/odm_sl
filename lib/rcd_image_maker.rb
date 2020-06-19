# frozen_string_literal: true

# Author: Bruce Tesar

require 'comparative_tableau_image'
require 'sheet'

# Creates a sheet representation of an RCD result object, i.e.,
# a comparative tableau of the ercs, typically winner-loser pairs,
# to which RCD was applied, with the constraints sorted according to
# the RCD-generated hierarchy, and the ercs sorted according to
# the highest-ranked W constraint.
class RcdImageMaker
  # Returns a new RCD image maker.
  #--
  # +comp_tableau_image_class+ and +sheet_class+ are dependency
  # injections used in testing.
  #++
  # :call-seq:
  #   RcdImageMaker.new -> image_maker
  def initialize(comp_tableau_image_class: ComparativeTableauImage,
                 sheet_class: Sheet)
    @comp_tableau_image_class = comp_tableau_image_class
    @sheet_class = sheet_class
  end

  # Returns a sheet with an image of +rcd_result+. The image consists
  # of a comparative tableau image, with the list of ERCs sorted with
  # respect to the constraint hierarchy of the RCD result.
  # :call-seq:
  #   get_image(rcd_result) -> sheet
  def get_image(rcd_result)
    sheet = @sheet_class.new
    ercs, constraints = construct_ercs_and_constraints(rcd_result)
    comp_tableau_image = @comp_tableau_image_class.new(ercs, constraints)
    sheet.put_range[1, 1] = comp_tableau_image
    sheet
  end

  # Constructs, from the RCD result, flat lists of the constraints and the
  # ERCs, sorted in the order in which they will appear in the tableau.
  def construct_ercs_and_constraints(rcd_result)
    # Create a flat list of all the constraints in ranked order
    sorted_cons = rcd_result.hierarchy.flatten
    # Retrieve the list of all of the ERCs.
    erc_list = rcd_result.erc_list
    # sort the ERCs with respect to the RCD constraint hierarchy
    sorted_ercs = sort_by_constraint_order(erc_list, sorted_cons)
    [sorted_ercs, sorted_cons]
  end
  private :construct_ercs_and_constraints

  # Takes a list of ERCs and sorts them with respect to a list of constraints,
  # such that all ERCs assigned a W by the first constraint occur first in
  # the sorted ERC list, followed by all the ERCs assigned an e by the first
  # constraint, followed by all the ERCs assigned an L by the first constraint.
  # Each of those blocks of ERCs is recursively sorted by the other constraints
  # in order.
  # Returns a sorted array of ERCs.
  #
  # This is used for display purposes, to create a monotonic "W boundary" in
  # formatted comparative tableaux.
  def sort_by_constraint_order(erc_list, con_list)
    # Base case for the recursion
    return erc_list if erc_list.empty? || con_list.empty?

    # Separate the first constraint from the rest
    con = con_list[0]
    con_rest = con_list.slice(1..-1)
    # partition the ercs by the first constraint: W, e, or L
    w_ercs, no_w_ercs = erc_list.partition { |e| e.w?(con) }
    l_ercs, e_ercs = no_w_ercs.partition { |e| e.l?(con) }
    # Order the blocks of ercs by W, then e, then L, recursively
    # sorting each block by the remaining (ordered) constraints
    sorted_ercs = []
    sorted_ercs.concat(sort_by_constraint_order(w_ercs, con_rest))
    sorted_ercs.concat(sort_by_constraint_order(e_ercs, con_rest))
    sorted_ercs.concat(sort_by_constraint_order(l_ercs, con_rest))
    sorted_ercs
  end
  private :sort_by_constraint_order
end

# Author: Bruce Tesar
# 

require_relative "comparative_tableau_image"
require_relative "sheet"

# A 2-dimensional sheet representation of an Rcd object, i.e.,
# a comparative tableau of the ercs, typically winner-loser pairs, to which
# RCD was applied, with the constraints sorted according to the RCD-generated
# hierarchy, and the ercs sorted according to the highest-ranked W constraint.
# 
# The constructor receives +rcd_result+, the object resulting from running
# RCD.
#
# This class delegates many methods to a Sheet object.
class RcdImage

  # The RCD results object
  attr_reader :rcd_result

  # Constructs a new RcdImage from an rcd_result object.
  # 
  # * +rcd_result+ - the result of an RCD execution (e.g., class Rcd).
  # * +comp_tableau_image_class+ - the class of object that will represent the
  #   comparative tableau image. This parameter has a default
  #   value of ComparativeTableauImage, and is used for testing
  #   (dependency injection).
  #
  # :call-seq:
  #   RcdImage.new(rcd_result) -> img
  #   RcdImage.new(rcd_result, comp_tableau_image_class: my_image_class) -> img
  def initialize(rcd_result,
    comp_tableau_image_class: ComparativeTableauImage)
    @rcd_result = rcd_result
    @comp_tableau_image_class = comp_tableau_image_class
    @sheet = Sheet.new
    construct_image
  end

  # Delegate all method calls not explicitly defined here to the sheet object.
  def method_missing(name, *args)
    @sheet.send(name, *args)
  end
  protected :method_missing
  
  # Construct sorted lists of ercs and constraints, and use them to
  # create a comparative tableau image. Built the RCD image from its
  # main part, the comparative tableau image.
  def construct_image
    ercs, constraints = construct_ercs_and_constraints
    @comp_tableau_image = @comp_tableau_image_class.new(ercs, constraints)
    @sheet.put_range[1,1] = @comp_tableau_image
  end
  protected :construct_image
  
  # Constructs, from the RCD result, flat lists of the constraints and the ERCs,
  # sorted in the order in which they will appear in the tableau.
  #
  # :call-seq:
  #   construct_ercs_and_constraints() -> [sorted_ercs, sorted_constraints]
  def construct_ercs_and_constraints
    # Create a flat list of all the constraints in ranked order
    sorted_cons = rcd_result.hierarchy.flatten
    # TODO: Rcd should provide a method returning a flat list of all ercs.
    # Create a flat list of all of the ercs
    erc_list = rcd_result.ex_ercs.flatten
    erc_list.concat(rcd_result.unex_ercs) unless rcd_result.unex_ercs.empty?
    # sort the ercs with respect to the RCD constraint hierarchy
    sorted_ercs = sort_by_constraint_order(erc_list,sorted_cons)
    return sorted_ercs, sorted_cons
  end
  protected :construct_ercs_and_constraints

  # Takes a list of ercs and sorts them with respect to a list of constraints,
  # such that all ercs assigned a W by the first constraint occur first in
  # the sorted erc list, followed by all the ercs assigned an e by the first
  # constraint, followed by all the ercs assigned an L by the first constraint.
  # Each of those blocks of ercs is recursively sorted by the other constraints
  # in order.
  # 
  # Returns a sorted array of ercs.
  #
  # This is used for display purposes, to create a monotonic "W boundary" in
  # formatted comparative tableaux.
  #
  # :call-seq:
  #   sort_by_constraint_order(erc_list, con_list) -> array
  def sort_by_constraint_order(erc_list, con_list)
    # Base case for the recursion
    return erc_list if erc_list.empty? or con_list.empty?
    # Separate the first constraint from the rest
    con = con_list[0]
    con_rest = con_list.slice(1..-1)
    # partition the ercs by the first constraint: W, e, or L
    w_ercs, no_w_ercs = erc_list.partition{|e| e.w?(con)}
    l_ercs, e_ercs = no_w_ercs.partition{|e| e.l?(con)}
    # Order the blocks of ercs by W, then e, then L, recursively
    # sorting each block by the remaining (ordered) constraints
    sorted_ercs = []
    sorted_ercs.concat(sort_by_constraint_order(w_ercs, con_rest))
    sorted_ercs.concat(sort_by_constraint_order(e_ercs, con_rest))
    sorted_ercs.concat(sort_by_constraint_order(l_ercs, con_rest))
    return sorted_ercs
  end
  protected :sort_by_constraint_order

end # class RcdImage

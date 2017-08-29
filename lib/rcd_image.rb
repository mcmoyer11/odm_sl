# Author: Bruce Tesar
# 

require_relative "ct_image"
require_relative "hierarchy"

# An RCD_image object represents the results of applying RCD to
# a comparative tableau. It is intended to serve as an interface
# between the internal representation of RCD results and
# the external representation as a sheet.
#
# It is derived from CT_image, which represents a basic CT, and adds
# elements relevant to representing RCD results in CT form.
class RCD_image < CT_image

  # The RCD results object
  attr_reader :rcd_result

  # Constructs a new RCD_image from an rcd_results object.
  #
  # ==== Parameters
  #
  # The parameter +arg_hash+ must be a hash with key/value pairs.
  # The hash key +:rcd+ must be defined.
  # * +:rcd+ - a +Rcd+ object (results of RCD execution).
  #
  # ==== Exceptions
  #
  # * ArgumentError if adequate keys are not present.
  #
  # ==== Examples
  #
  #   RCD_image.new({:rcd=>rcd_result})
  #
  def initialize(arg_hash)
    # process the method parameter
    if arg_hash.has_key?(:rcd) then
      @rcd_result = arg_hash[:rcd]
    else
      msg = "RCD_image.new must receive a hash with the :rcd key defined."
      raise ArgumentError, msg
    end
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
    @hier_with_unranked = Hierarchy.new
    @hier_with_unranked.concat(@rcd_result.hierarchy)
    @hier_with_unranked << @rcd_result.unranked unless @rcd_result.unranked.empty?
    # Create a flat list of the constraints in sorted order
    sorted_cons = @hier_with_unranked.flatten
    # sort the ercs with respect to the RCD constraint hierarchy
    sorted_ercs, @ercs_by_stratum, @explained_ercs = RCD_image.sort_rcd_results(@rcd_result)
    return sorted_ercs, sorted_cons
  end
  protected :construct_ercs_and_constraints

  # Constructs the formatting commands for the image.
  #--
  # Calls #super to apply the standard tableau formatting, and then adds
  # the formatting commands for stratified tableau borders, and for
  # RCD-style cell coloring.
  def construct_formatting
    super
    stratified_tableau_borders
    rcd_tableau_coloring
  end
  protected :construct_formatting

  # Puts stratified tableau borders on a tableau, based on stratification
  # of both the constraint hierarchy and the ercs.
  def stratified_tableau_borders
    hier_by_stratum = @hier_with_unranked.to_enum
    ercs_by_stratum = @ercs_by_stratum.to_enum
    vl_col_index = first_con_col - 1
    hl_row_index = first_erc_row - 1
    loop do
      # Find the next stratum of constraints, and draw a border to the right
      vl_col_index += hier_by_stratum.next.size
      stratum_right_edge =
        CellRange.new(ROW1,vl_col_index,last_erc_row,vl_col_index)
      add_formatting(BorderWeight.new(stratum_right_edge, :medium, :right))
      # Find the ercs accounted for by the next stratum, and draw a border beneath
      hl_row_index += ercs_by_stratum.next.size
      cluster_bottom_edge =
        CellRange.new(hl_row_index,COL1,hl_row_index,last_con_col)
      add_formatting(BorderWeight.new(cluster_bottom_edge, :medium, :bottom))
    end
  end
  protected :stratified_tableau_borders

  # Constructs RCD-determined tableau coloring, based on stratification.
  def rcd_tableau_coloring
    hier_by_stratum = @hier_with_unranked.to_enum
    ercs_by_stratum = @ercs_by_stratum.to_enum
    stratum_col_last = first_con_col - 1 # init to col before first stratum
    stratum_row_last = first_erc_row - 1 # init to row before first stratum
    loop do
      # Determine number of columns and col indices for the current stratum
      stratum_con_count = hier_by_stratum.next.size
      stratum_col_first = stratum_col_last + 1
      stratum_col_last += stratum_con_count
      # Determine number of rows and row indices for the current stratum
      stratum_erc_count = ercs_by_stratum.next.size
      stratum_row_first = stratum_row_last
      stratum_row_first += 1 unless (stratum_erc_count==0)
      stratum_row_last += stratum_erc_count
      # Format with respect to the current stratum
      format_stratum(stratum_row_first,stratum_col_first,stratum_row_last,
        stratum_col_last)
    end
  end # rcd_tableau_coloring()
  protected :rcd_tableau_coloring

  # Formats the relevant cells associated with the given stratum.
  # The constraints of the stratum are those with column indices between
  # +stratum_col_first+ and +stratum_col_last+. The ERCs associated
  # with the stratum are those between +stratum_row_first+ and
  # +stratum_row_last+.
  #
  # * If the associated ERCs are unexplained, then the stratum's constraint
  #   headings and evaluation cells are colored red, as are the ERC labels.
  # * If the current stratum is final and there are no unexplained ERCs,
  #   the stratum's constraint headings are colored gold.
  # * For a non-final stratum, the constraint headings and associated 'W'
  #   evaluation cells are colored with #next_stratum_color.
  # * If the current stratum's associated ERCs are the final ERC block,
  #   then the current stratum is penultimate. In addition to coloring
  #   the relevant cells for the current stratum, the 'L' evaluation cells
  #   of the current ERCs for the *final* stratum of constraints are
  #   colored gold, indicating why those constraints must be in the final
  #   stratum.
  def format_stratum(stratum_row_first,stratum_col_first,stratum_row_last,
      stratum_col_last)
    # Determine if this stratum's ERCs are unexplained (due to inconsistency).
    last_expl_row_index = (first_erc_row - 1) + @explained_ercs.size
    unexplained_stratum = (stratum_row_first > last_expl_row_index)
    # Set ranges of constraint headings and constraint evaluations
    # for the current stratum.
    con_name_range = CellRange.new(heading_row,stratum_col_first,
      heading_row,stratum_col_last)
    con_eval_range = CellRange.new(stratum_row_first,stratum_col_first,
      stratum_row_last,stratum_col_last)
    # Determine if the current stratum is final, and if the current erc
    # block is the final one (meaning the current stratum is penultimate).
    final_stratum = (stratum_col_last==last_con_col)
    final_erc_block = (stratum_row_last==last_erc_row)
    if unexplained_stratum then
      erc_label_range = CellRange.new(stratum_row_first, COL1,
        stratum_row_last, COL1)
      color_unexplained_stratum(con_name_range,con_eval_range,erc_label_range)
    elsif final_stratum then
      add_formatting(CellColor.new(con_name_range, :gold))
    elsif final_erc_block then
      color_stratum(con_name_range,con_eval_range,next_stratum_color)
      # Color the 'L' containing cells of the final ERC block for
      # the final (next) stratum (highlighting why those constraints must be
      # dominated by a constraint of the current stratum).
      final_range = CellRange.new(stratum_row_first,stratum_col_last+1,
        stratum_row_last,last_con_col)
      color_l_cells(final_range, :gold)
    else
      color_stratum(con_name_range,con_eval_range,next_stratum_color)
    end
  end
  protected :format_stratum

  # For a stratum of constraints, and a set of ERCs explained by
  # that stratum, colors the constraint column heading cells and
  # the evaluation cells (cells in which one of the stratum's constraints
  # assigns a 'W' to one of the explained ERCs).
  def color_stratum(con_name_range,con_eval_range,color)
    add_formatting(CellColor.new(con_name_range, color))
    color_filled_cells(con_eval_range, color)
  end
  protected :color_stratum

  # For the unexplained stratum of constraints and corresponding unexplained
  # ERCs of an inconsistent ERC set, colors the constraint column heading cells,
  # the evaluation cells, and the erc label cells. All are colored red.
  def color_unexplained_stratum(con_name_range,con_eval_range,erc_label_range)
    color = :red
    color_stratum(con_name_range,con_eval_range,color)
    add_formatting(CellColor.new(erc_label_range, color))
  end
  protected :color_unexplained_stratum

  # Sets the interior color of all the cells in +range+ that are not empty
  # to the color +color+.
  def color_filled_cells(range, color)
    range.each do |cell|
      next if sheet.get_cell(cell).nil?
      add_formatting(CellColor.new(cell.to_cellrange, color))
    end
  end
  protected :color_filled_cells

  # Sets the interior color of all the cells in +range+ that contain 'L'
  # to the color +color+.
  def color_l_cells(range, color)
    range.each do |cell|
      next unless sheet.get_cell(cell)=='L'
      add_formatting(CellColor.new(cell.to_cellrange, color))
    end
  end
  protected :color_l_cells

  # Alternately yields each of two colors, for coloring alternating
  # non-final strata.
  # The first call returns :brightgreen, the second returns :brightcyan,
  # the third :brightgreen, and so forth.
  #
  # :call-seq:
  #   next_stratum_color() -> symbol
  def next_stratum_color
    # Initialize the generator if not already initialized
    @color_generator ||= Fiber.new do
      loop do
        Fiber.yield :brightgreen
        Fiber.yield :brightcyan
      end
    end
    # Return the next generated color
    @color_generator.resume
  end
  protected :next_stratum_color

  # Sort the ercs of an RCD result in several ways.
  #
  # :call-seq:
  #   RCD_image.sort_rcd_results(rcd_result) -> [sorted_ercs, ercs_by_stratum, explained_ercs]
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
  def RCD_image.sort_rcd_results(rcd_result)
    # Sort each "stratum" of ercs by the order of the constraints in the
    # corresponding constraint hierarchy stratum, so that the ercs assigned
    # a W by the first constraint in the stratum appear first, etc.
    flat_hier = rcd_result.hierarchy.flatten
    flat_hier.concat(rcd_result.unranked) unless rcd_result.unranked.empty?
    ercs_by_stratum = []
    rcd_result.ex_ercs.each do |ercs|
      ercs_by_stratum << RCD_image.sort_by_constraint_order(ercs,flat_hier)
    end
    explained_ercs = ercs_by_stratum.flatten # in sorted order

    # add any unexplained ercs as the last level of the stratified erc list.
    unex_ercs = []
    unless rcd_result.unex_ercs.empty? then
      unex_ercs = RCD_image.sort_by_constraint_order(rcd_result.unex_ercs, flat_hier)
      ercs_by_stratum << unex_ercs
    end

    # create a CT with the ercs in sorted order
    sorted_ercs = Comparative_tableau.new
    sorted_ercs.concat(explained_ercs)
    sorted_ercs.concat(unex_ercs)

    return sorted_ercs, ercs_by_stratum, explained_ercs
  end

end # class RCD_image

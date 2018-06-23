# Author: Bruce Tesar
# 

require_relative 'tableau_image'

# This abstract class derives from Tableau_image, contributing resources
# related to representing the evaluation of ERCs by constraints. It does
# not define the pre-constraint columns, leaving that to concrete
# subclasses.
# 
# Concrete subclasses must initialize the following instance variables:
# * #last_erc_row
#   (set by: #construct_constraint_columns_image)
# * Tableau_image#first_con_col
# * Tableau_image#last_con_col
# * Tableau_image#constraints
class ERCs_image < Tableau_image

  # Initializes the list of ERCs (to an empty array) and the first ERC row.
  def initialize
    @ercs = []
    super()
    @first_erc_row = heading_row + 1 # heading_row() must be called after super().
  end

  # Returns the winner-loser pairs of the CT, in top to bottom order of
  # their appearance in the tableau.
  def ercs
    @ercs
  end

  # Resets the list of winner-loser pairs to +erc_list+.
  def ercs=(erc_list)
    @ercs = erc_list
  end
  protected :ercs=

  # Returns the row index of the first erc.
  def first_erc_row
    @first_erc_row
  end

  # Returns the row index of the last erc.
  def last_erc_row
    @last_erc_row
  end

  # Returns the index range for the ERC rows.
  def erc_range
    (first_erc_row..last_erc_row)
  end

  # Returns the image representation of the preference by constraint +con+
  # for the erc represented in the image row +ct_row+.
  #
  # Returns:
  # * "L" if the constraint prefers the loser.
  # * "W" if the constraint prefers the winner.
  # * nil if the constraint has no preference (to be interpreted as an empty cell)
  def preference_to_s(ct_row, con)
    return "L" if ct_row.l?(con)
    return "W" if ct_row.w?(con)
    return nil  # Leave 'e' cells blank, for readability
  end
  protected :preference_to_s

  def construct_constraint_columns_image
    # write the constraint column headings
    self.last_con_col = first_con_col + constraints.size - 1
    con_col = first_con_col
    constraints.each do |con|
      self.sheet[heading_row,con_col] = con.to_s
      con_col += 1
    end
    # write the constraint preferences for the ercs
    @last_erc_row = heading_row
    ercs.each do |erc|
      @last_erc_row += 1
      con_col = first_con_col
      constraints.each do |con|
        self.sheet[@last_erc_row,con_col] = preference_to_s(erc,con)
        con_col += 1
      end
    end
  end
  protected :construct_constraint_columns_image

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
  #   ERCs_image.sort_by_constraint_order(erc_list, constraint_list) -> array
  def ERCs_image.sort_by_constraint_order(ercs,cons)
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

end # class ERCs_image

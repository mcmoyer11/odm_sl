# Author: Bruce Tesar
# 

# Exception class to identify errors raised with respect to
# sheet representations.
#
# ==== Examples
#
#   raise SheetError.new(invalid_cell_list), "Prompt to be displayed"
#
# To raise an exception without identifying specific image cells:
#
#   raise SheetError.new([]), "Prompt to be displayed"
class SheetError < StandardError

  # Constructs a SheetError.
  #
  # ==== Parameters
  #
  # * +invalid_cell_list+ - a list of the invalid cells that triggered
  #   the exception.
  def initialize(invalid_cell_list)
    @invalid_cells = invalid_cell_list
  end

  # Returns the list of invalid cells that triggered the exception.
  def invalid_cells
    @invalid_cells
  end
  
end # class SheetError

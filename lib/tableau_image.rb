# Author: Bruce Tesar
# 

require_relative 'cell'
require_relative 'cellrange'
require_relative 'constraint'
require_relative 'sheet'

# An abstract class defining some elements common to all tableaux.
#
# The tableau abstraction divides the columns of a tableau into
# the pre-constraint columns and the constraint evaluation columns.
# It divides the rows into a (column) heading row, followed by
# rows for the entities (typically candidates or winner/loser pairs)
# being evaluated, along with their evaluation by the constraints.
#
# Tableau_image leaves the content of the pre-constraint columns to
# be defined and supplied by subclasses. The headings of the constraint
# columns are the names of constraints; the list of the constraints must
# be supplied by subclasses.
#
# Concrete subclasses must initialize the following instance variables:
# * #first_con_col
# * #last_con_col
# * #constraints
#--
# These are not initialized in a constructor here because the concrete
# subclasses may need to do a non-trivial amount of computation prior
# to initializing the variables, computation that may require construction
# of other base class resources.
class Tableau_image

  # The index of the first row.
  ROW1 = 1

  # The index of the first column.
  COL1 = 1

  # Initializes the sheet field to a new (empty) sheet, and sets
  # the heading row to index 1.
  def initialize
    @heading_row = 1
    @sheet = Sheet.new
  end

  # Returns the sheet representation.
  def sheet
    @sheet
  end

  # Resets the sheet representation to +sheet_obj+.
  def sheet=(sheet_obj)
    @sheet = sheet_obj
  end
  protected :sheet=

  # The constraints, in left to right order of their appearance in the tableau.
  def constraints
    @constraints
  end

  # Resets the constraint list to +con_list+.
  def constraints=(con_list)
    @constraints = con_list
  end
  protected :constraints=

  # Returns the number of rows in the sheet.
  def row_count
    sheet.row_count
  end

  # Returns the number of columns in the sheet.
  def col_count
    sheet.col_count
  end

  # Returns the index of the row containing the column headings.
  def heading_row
    @heading_row
  end

  # Resets the heading row index to +heading_row_index+.
  def heading_row=(heading_row_index)
    @heading_row = heading_row_index
  end
  protected :heading_row=

  # Returns the index of the first constraint column.
  def first_con_col
    @first_con_col
  end

  # Resets the first constraint column.
  def first_con_col=(first_constraint_column)
    @first_con_col = first_constraint_column
  end
  protected :first_con_col=

  # Returns the index of the last constraint column.
  def last_con_col
    @last_con_col
  end

  # Resets the last constraint column.
  def last_con_col=(last_constraint_column)
    @last_con_col = last_constraint_column
  end
  protected :last_con_col=

  # Returns the index range for the constraint columns.
  def con_range
    (first_con_col..last_con_col)
  end

end # class Tableau_image

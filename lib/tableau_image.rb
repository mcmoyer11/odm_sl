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
# * #last_con_col (set by: #validate_constraint_headings)
# * #constraints (set by: #extract_constraints)
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

  # Checks to make sure that there is at least one constraint in the
  # tableau, and sets the index of the last constraint column (when reading
  # the image from a sheet).
  def validate_constraint_headings
    # Constraint columns go from first_con up to the first following empty cell
    # in row 1.
    self.last_con_col = first_con_col-1
    self.last_con_col += 1 until sheet[heading_row,last_con_col+1].nil?
    if (last_con_col < first_con_col) then  # no constraint column heading
      msg = "The CT has no constraints."
      raise SheetError.new([]), msg
    end
  end

  # Extract the constraint information from the column headings of a tableau.
  # If the constraints aren't already
  # numbered, automatic numbering is applied to them. Each label used
  # to construct a Constraint object.
  # Returns true.
  def extract_constraints
    self.constraints = []
    # Read the constraint labels from the column heading cells
    con_range.each{|col| constraints << sheet.get_cell(Cell.new(heading_row,col))}
    # Construct constraint objects
    constraints.each_index do |i|
      # If constraints are already numbered, keep that numbering.
      con_str = constraints[i].to_s
      if (con_str =~ /^(\d+):/) then
        constraints[i] = Constraint.new($POSTMATCH,$1)
      else # otherwise, number them from 1 in the order they appear.
        constraints[i] = Constraint.new(con_str,i+1)
      end
    end
    return true
  end

end # class Tableau_image

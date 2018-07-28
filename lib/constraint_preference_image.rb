# Author: Bruce Tesar

require 'sheet'

# A 2-dimensional sheet representation of a set of constraint preferences
# for ercs. The sheet has one column for each constraint, and one row for
# each erc, along with a header row containing the string name of each
# constraint.
# 
# The constructor receives two parameters: +ercs+ and +constraints+. These
# are passed as separate parameters so that the sheet can list the erc
# rows in in the order that the ercs appear in +ercs+, and the constraint
# columns can appear in the order that the constraints appear in +constraints+.
#
# This class delegates many methods to a Sheet object, and thus will respond
# to all methods defined in Sheet.
class ConstraintPreferenceImage
  
  # The sheet index of the header row
  HEADER_ROW = 1
  
  # Creates a new preference image, with a header row, a row for each erc
  # and a column for each constraint.
  # * +ercs+ - the ercs, in the order that their rows will appear.
  # * +constraints+ - the constraints, in the order that their columns will
  #   appear.
  def initialize(ercs, constraints)
    @ercs = ercs
    @constraints = constraints
    @sheet = Sheet.new
    construct_image
  end

  # Delegate all method calls not explicitly defined here to the sheet object.
  def method_missing(name, *args, &block)
    @sheet.send(name, *args, &block)
  end
  protected :method_missing

  # Constructs the overall image in the sheet.
  def construct_image
    construct_column_headings
    construct_preferences
  end
  protected :construct_image
  
  # Constructs the column heading row: each column is headed by the string
  # name of the corresponding constraint.
  def construct_column_headings
    @constraints.each_with_index do |con, col_idx|
      col = col_idx + 1
      @sheet[HEADER_ROW,col] = con.to_s
    end
  end
  protected :construct_column_headings

  # Constructs the rows of constraint preferences, one for each erc.
  #---
  # #each_with_index returns the index of each element in the container,
  # starting from *zero*, whereas Sheet objects start counting rows and
  # columns from 1, so an extra 1 is always added to each container index
  # to get the corresponding row or column index.
  def construct_preferences
    @ercs.each_with_index do |erc, row_idx|
      row = HEADER_ROW + row_idx + 1
      @constraints.each_with_index do |con, col_idx|
        col = col_idx + 1
        @sheet[row,col] = preference_to_s(erc, con)
      end
    end
  end
  protected :construct_preferences
  
  # Returns the image representation of the preference by constraint +con+
  # for erc +erc+.
  #
  # Returns:
  # * "L" if the constraint prefers the loser.
  # * "W" if the constraint prefers the winner.
  # * nil if the constraint has no preference (interpreted as an empty cell)
  def preference_to_s(erc, con)
    return "L" if erc.l?(con)
    return "W" if erc.w?(con)
    return nil  # Leave 'e' cells blank, for readability
  end
  protected :preference_to_s

end # class ConstraintPreferenceImage

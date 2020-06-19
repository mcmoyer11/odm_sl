# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'

# Constructs a sheet representation of a set of constraint preferences
# for ercs. The sheet has one column for each constraint, and one row for
# each erc, along with a header row containing the string name of each
# constraint.
class PreferenceImageMaker
  # The sheet index of the header row
  HEADER_ROW = 1

  # Returns a new constraint preference image maker.
  # :call-seq:
  #   PreferenceImageMaker.new -> image_maker
  #--
  # +sheet_class+ is a dependency injection used for testing.
  def initialize(sheet_class: Sheet)
    @sheet_class = sheet_class
  end

  # Returns a sheet with a constraint preference image,
  # based on +ercs+ and +constraints+.
  # :call-seq:
  #   get_image(ercs, constraints) -> sheet
  def get_image(ercs, constraints)
    sheet = @sheet_class.new
    construct_column_headings(constraints, sheet)
    construct_preferences(ercs, constraints, sheet)
    sheet
  end

  # Constructs the column heading row: each column is headed by
  # the string name of the corresponding constraint.
  def construct_column_headings(constraints, sheet)
    constraints.each_with_index do |con, col_idx|
      col = col_idx + 1
      sheet[HEADER_ROW, col] = con.to_s
    end
  end
  private :construct_column_headings

  # Constructs the rows of constraint preferences, one for each erc.
  #--
  # #each_with_index returns the index of each element in the container,
  # starting from *zero*, whereas Sheet objects start counting rows and
  # columns from 1, so an extra 1 is always added to each container index
  # to get the corresponding row or column index.
  def construct_preferences(ercs, constraints, sheet)
    ercs.each_with_index do |erc, row_idx|
      row = HEADER_ROW + row_idx + 1
      constraints.each_with_index do |con, col_idx|
        col = col_idx + 1
        sheet[row, col] = preference_to_s(erc, con)
      end
    end
  end
  private :construct_preferences

  # Returns:
  # * "L" if +con+ prefers the loser for +erc+.
  # * "W" if +con+ prefers the winner for +erc+.
  # * nil if +con+ has no preference for +erc+.
  def preference_to_s(erc, con)
    return 'L' if erc.l?(con)
    return 'W' if erc.w?(con)

    nil # Leave 'e' cells blank (nil), for readability
  end
  private :preference_to_s
end

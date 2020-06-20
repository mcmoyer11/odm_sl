# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'preference_image_maker'

# Creates a sheet representation of a comparative tableau, i.e.,
# a list of ercs, typically winner-loser pairs, and the preference
# of each constraint on each erc.
class CtImageMaker
  # The sheet index of the header row
  HEADER_ROW = 1 #:nodoc:

  # The sheet indices of the erc information columns.
  LABEL_COL = 1 #:nodoc:
  INPUT_COL = LABEL_COL + 1 #:nodoc:
  WINNER_COL = INPUT_COL + 1 #:nodoc:
  LOSER_COL = WINNER_COL + 1 #:nodoc:
  FIRST_CONSTRAINT_COL = LOSER_COL + 1 #:nodoc:

  # Returns a new comparative tableau image maker.
  #--
  # +pref_image_maker+ is a dependency injection used for testing.
  #++
  # :call-seq:
  #   CtImageMaker.new -> image_maker
  def initialize(pref_image_maker: PreferenceImageMaker.new,
                 sheet_class: Sheet)
    @pref_image_maker = pref_image_maker
    @sheet_class = sheet_class
  end

  # Returns a sheet with a Constraint Tableau image,
  # built from the constraint preference information in
  # +ercs+ and +constraints+.
  # :call-seq:
  #   get_image(ercs, constraints) -> sheet
  def get_image(ercs, constraints)
    sheet = @sheet_class.new
    construct_column_headings(sheet)
    construct_erc_info(ercs, sheet)
    add_preference_image(ercs, constraints, sheet)
    sheet
  end

  # Put the column headings in the header row of the sheet.
  def construct_column_headings(sheet)
    sheet[HEADER_ROW, LABEL_COL] = "ERC\#"
    sheet[HEADER_ROW, INPUT_COL] = 'Input'
    sheet[HEADER_ROW, WINNER_COL] = 'Winner'
    sheet[HEADER_ROW, LOSER_COL] = 'Loser'
  end
  private :construct_column_headings

  # Construct the non-preference erc info for each erc, putting
  # the erc label and candidate info into the appropriate columns.
  def construct_erc_info(ercs, sheet)
    ercs.each_with_index do |erc, row_idx|
      row = HEADER_ROW + row_idx + 1
      sheet[row, LABEL_COL] = erc.label
      fill_candidate_info_columns(erc, row, sheet)
    end
  end
  private :construct_erc_info

  # If an erc is a "pure" erc instead of a winner-loser pair,
  # then the cells for that erc in the Input, Winner,
  # and Loser columns are left with the value nil.
  def fill_candidate_info_columns(erc, row, sheet)
    if erc.respond_to?(:winner) # erc contains a winner and a loser
      sheet[row, INPUT_COL] = erc.winner.input.to_s
      sheet[row, WINNER_COL] = erc.winner.output.to_s
      sheet[row, LOSER_COL] = erc.loser.output.to_s
    else
      sheet[row, INPUT_COL] = nil
      sheet[row, WINNER_COL] = nil
      sheet[row, LOSER_COL] = nil
    end
    sheet
  end
  private :fill_candidate_info_columns

  # Constructs an image of the constraint preferences for the ercs
  # and adds it to the main CT image, starting from the cell
  # in the header row and the first constraint column.
  def add_preference_image(ercs, constraints, sheet)
    pref_image = @pref_image_maker.get_image(ercs, constraints)
    sheet.put_range(HEADER_ROW, FIRST_CONSTRAINT_COL, pref_image)
  end
  private :add_preference_image
end

# Author: Bruce Tesar

require_relative 'ercs_image'
require_relative "ct_wl_pair"
require_relative "sheet_error"
require_relative "cell"
require_relative "cellrange"
require_relative "sheet"

# A CT_image object represents a comparative tableau and its canonical
# table representation. It is intended to serve as an interface
# between the internal representation of lists of ERCs and constraints, and
# the external representation in a spreadsheet-like table format.
class CT_image < ERCs_image

  NUMBER_COL = COL1 #:nodoc:
  INPUT_COL = NUMBER_COL + 1 #:nodoc:
  WINNER_COL = INPUT_COL + 1 #:nodoc:
  LOSER_COL = WINNER_COL + 1 #:nodoc:
  PRE_CON_COLUMNS = 4 #:nodoc:

  # Constructs a new CT_image from either a sheet or
  # an erc list / constraint list pair.
  #
  # ==== Parameters
  #
  # The parameter +arg_hash+ must be a hash with key/value pairs.
  # If creating from a table image, the hash key +:sheet+ should be defined.
  # If creating from ERCs, the hash keys +:ercs+ and
  # +:constraints+ must be defined.
  # * +:sheet+ - a CT sheet
  # * +:ercs+ - a list of the ercs/winner-loser pairs of the CT
  # * +:constraints+ - a list of constraints, in the order in which
  #   the constraint columns should appear.
  #
  # ==== Exceptions
  #
  # * ArgumentError if adequate keys are not present.
  # * SheetError when an invalid CT sheet is encountered.
  #
  # ==== Examples
  #
  #   CT_image.new({:sheet=>ct_sheet})
  #   CT_image.new({:ercs=>list_of_ercs, :constraints=>sorted_constraint_list})
  #
  def initialize(arg_hash)
    self.first_con_col = PRE_CON_COLUMNS + 1
    super()
    # process the method parameter
    if arg_hash.has_key?(:sheet) then
      self.sheet = arg_hash[:sheet]
      validate
      construct_sorted_ercs_and_cons
    elsif arg_hash.has_key?(:ercs) and arg_hash.has_key?(:constraints) then
      self.ercs = arg_hash[:ercs]
      self.constraints = arg_hash[:constraints]
      construct_image
      construct_formatting
    else
      msg = "CT_image.new must receive a hash with either :sheet or both (:ercs and :constraints)."
      raise ArgumentError, msg
    end
  end

  # Validates a CT sheet.
  # Returns +true+ if there are no validation failures; otherwise,
  # an exception is raised.
  #
  # ==== Exceptions
  #
  # SheetError - the exception will contain a list of invalid cells.
  def validate
    # check first row column headings
    validate_pre_constraint_headings
    validate_constraint_headings
    # Determine the number of ERC rows
    count_erc_rows
    # Check the ERC evaluation values
    validate_constraint_evaluations
    return true # no exceptions were raised, so the sheet is valid.
  end
  protected :validate

  # Validates the pre-constraint column headings.
  # Called when +new+ is provided with a sheet.
  #
  # Returns +true+ if there are no validation failures; otherwise,
  # an exception is raised.
  #
  # ==== Exceptions
  # 
  # SheetError - invalid column headings.
  def validate_pre_constraint_headings
    invalid_cell_list = []
    invalid_cell_list << Cell.new(heading_row,NUMBER_COL) unless sheet[heading_row,NUMBER_COL]=="ERC#"
    invalid_cell_list << Cell.new(heading_row,INPUT_COL) unless sheet[heading_row,INPUT_COL]=="Input"
    invalid_cell_list << Cell.new(heading_row,WINNER_COL) unless sheet[heading_row,WINNER_COL]=="Winner"
    invalid_cell_list << Cell.new(heading_row,LOSER_COL) unless sheet[heading_row,LOSER_COL]=="Loser"
    # Raise an exception for any invalid values.
    unless invalid_cell_list.empty? then
      msg = "There are invalid column headings.\n" +
        "The cells with invalid values have been colored red."
      raise SheetError.new(invalid_cell_list), msg
    end
    return true
  end
  protected :validate_pre_constraint_headings

  # Extracts the information from the valid CT table image, and constructs
  # the list of ercs +ercs+ and the list of constraints +constraints+.
  # Both lists preserve the order of occurrence in the CT table image.
  def construct_sorted_ercs_and_cons
    # Get the constraints from the column headings
    extract_constraints
    # get the pre-constraint-column candidate info for each erc
    get_wl_pair_candidate_info
    # get the constraint preferences for each erc
    get_constraint_preferences
    return true
  end
  protected :construct_sorted_ercs_and_cons

  # Read the pre-constraint-column candidate info, and create a CT-specific
  # winner-loser pair, for each WL row in the CT. Store the winner-loser pairs
  # using #ercs() (a method inherited from class ERCs_image).
  def get_wl_pair_candidate_info
    # Get candidate info for winner/loser pairs
    erc_range.each do |row|
      erc_number = sheet[row,NUMBER_COL]
      input = sheet[row,INPUT_COL]
      win_output = sheet[row,WINNER_COL]
      lose_output = sheet[row,LOSER_COL]
      # create a CT-specific winner-loser pair from just the CT info
      winner = Candidate.new(input, win_output, "Yes", constraints)
      loser = Candidate.new(input, lose_output, "No", constraints)
      wl_pair = CT_wl_pair.new(winner, loser, erc_number)
      ercs[row-erc_range.first] = wl_pair
    end
  end
  protected :get_wl_pair_candidate_info

  # Uses the given lists of ercs and constraints,
  # and constructs the corresponding CT sheet.
  def construct_image
    construct_constraint_columns_image
    construct_pre_constraint_columns_image
  end
  protected :construct_image

  # Construct the sheet image for the pre-constraint columns, i.e.,
  # the columns for ERC#, Input, Winner, Loser.
  def construct_pre_constraint_columns_image
    # first row contains the column headers
    sheet[heading_row,NUMBER_COL] = "ERC\#"
    sheet[heading_row,INPUT_COL] = "Input"
    sheet[heading_row,WINNER_COL] = "Winner"
    sheet[heading_row,LOSER_COL] = "Loser"
    # add the pre-constraint erc info to the sheet
    row = heading_row
    ercs.each do |erc|
      row += 1
      sheet[row,NUMBER_COL] = erc.label
      if erc.respond_to?(:winner) then # pair contains a winner and a loser
        sheet[row,INPUT_COL] = erc.winner.input.to_s
        sheet[row,WINNER_COL] = erc.winner.output.to_s
        sheet[row,LOSER_COL] = erc.loser.output.to_s
      else
        sheet[row,INPUT_COL] = nil
        sheet[row,WINNER_COL] = nil
        sheet[row,LOSER_COL] = nil
      end
    end
  end
  protected :construct_pre_constraint_columns_image

  # Construct all of the necessary formatting for the tableau.
  def construct_formatting
    construct_tableau_formatting
  end
  protected :construct_formatting

end # class CT_image

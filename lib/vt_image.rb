# Author: Bruce Tesar
# 

require_relative 'tableau_image'
require_relative 'candidate'
require_relative 'competition'
require_relative 'competition_list'
require_relative "sheet_error"
require_relative "cell"
require_relative "cellrange"
require_relative "sheet"

# Defines the image of a Violation Tableau (VT), in which individual
# candidates are listed on separate rows, along with their constraint
# violation profiles and an indication of (non)optimality.
class VT_image < Tableau_image
  
  # Constructs a new VT_image from either a raw sheet image or
  # a list of candidate competitions.
  #
  # ==== Parameters
  #
  # The parameter +arg_hash+ must be a hash with key/value pairs.
  # If creating from an image, the hash key +:sheet+ should be defined.
  # If creating from a competition list, the hash key +:competition_list+
  # must be defined.
  #
  # ==== Exceptions
  #
  # * ArgumentError if adequate keys are not present.
  # * SheetError when invalid VT image formatting is encountered.
  #
  # ==== Examples
  #
  #   VT_image.new({:sheet=>sheet_image})
  #   VT_image.new({:competition_list=>list_of_competitions})
  #
  def initialize(arg_hash)
    @first_cand_row = ROW1 + 1
    super()
    if arg_hash.has_key?(:sheet) then
      self.sheet = arg_hash[:sheet]
      validate
      construct_competition_list
    elsif arg_hash.has_key?(:competition_list) then
      @competition_list = arg_hash[:competition_list]
      # Initialize the pre-constraint and first constraint column indices
      @number_col = COL1
      @input_col = @number_col + 1
      @output_col = @input_col + 1
      @opt_col = @output_col + 1
      self.first_con_col = @opt_col + 1
      construct_image
      construct_formatting
    else
      msg = "VT_image.new must receive a hash with either :sheet or :competition_list"
      raise ArgumentError, msg
    end
  end

  # Returns the row index of the first candidate.
  def first_cand_row() @first_cand_row end

  # Returns the row index of the last candidate.
  def last_cand_row() @last_cand_row end

  # Returns the range of row indices for the candidate rows.
  def cand_range()
    (first_cand_row..last_cand_row)
  end

  # Returns the list of competitions in the tableau.
  def competition_list() @competition_list end

  # Returns the column index of the candidate numbers; returns nil
  # if there is no candidate number column.
  def number_col() @number_col end

  # Returns the column index of the input column.
  def input_col() @input_col end

  # Returns the column index of the output column.
  def output_col() @output_col end

  # Returns the column index of the Opt column (indicating if a candidate
  # is optimal).
  def opt_col() @opt_col end

  # Returns the column index of the Remarks column.
  def remark_col() last_con_col + 2 end

  # Validates a VT table image.
  # Returns +true+ if there are no validation failures; otherwise,
  # +SheetError+ is raised.
  #
  # ==== Exceptions
  #
  # +SheetError+ - the exception will contain a list of invalid cells.
  def validate
    validate_pre_constraint_headings
    validate_constraint_headings
    count_cand_rows
    # Check the pre-constraint column values
    check_first_candidate_input
    check_blank_output_rows
    validate_opt_column
    # Check the constraint column values
    validate_constraint_evaluations
    return true # no exceptions were raised, so the image is valid.
  end
  protected :validate

  def validate_pre_constraint_headings
    @number_col = COL1 # if candidates are numbered, numbers are in first column
    first_col_val = sheet[heading_row,number_col]
    if !first_col_val.nil? and first_col_val.to_str.strip.upcase=='CAND#' then
      @input_col = COL1 + 1 # inputs
    else
      @number_col = nil # no candidate number column is present.
      @input_col = COL1
    end
    # Set the other numbers for defined columns
    @output_col = input_col + 1
    @opt_col = output_col + 1
    self.first_con_col = opt_col + 1
    # Check the other pre-constraint column headings
    invalid_cell_list = []
    in_heading = sheet[heading_row,input_col]
    if in_heading.nil? || in_heading.strip.upcase!="INPUT" then
      invalid_cell_list << Cell.new(heading_row,input_col)
    end
    out_heading = sheet[heading_row,output_col]
    if out_heading.nil? || out_heading.strip.upcase!="OUTPUT" then
      invalid_cell_list << Cell.new(heading_row,output_col)
    end
    opt_heading = sheet[heading_row,opt_col]
    if opt_heading.nil? || opt_heading.strip.upcase!="OPT" then
      invalid_cell_list << Cell.new(heading_row,opt_col)
    end
    # Raise an exception for any invalid values.
    unless invalid_cell_list.empty? then
      msg = "There are invalid column headings.\n" +
        "The cells with invalid values have been colored red."
      raise SheetError.new(invalid_cell_list), msg
    end
    return true
  end
  protected :validate_pre_constraint_headings

  def count_cand_rows
    @last_cand_row = row_count
    if (last_cand_row < first_cand_row) then
      msg = "The sheet has no candidate rows."
      raise SheetError.new([]), msg
    end
    return true
  end
  protected :count_cand_rows

  def check_first_candidate_input
    if sheet[first_cand_row,input_col].nil? then
      msg = "The first candidate of a VT must have a specified input."
      raise SheetError.new([Cell.new(first_cand_row,input_col)]), msg
    end
  end
  protected :check_first_candidate_input

  def check_blank_output_rows
    # Check that rows with no output are completely blank
    invalid_cell_list = []
    cand_range.each do |row|
      if sheet[row,output_col].nil? then
        (COL1..last_con_col).each do |col|
          invalid_cell_list << Cell.new(row,col) unless sheet[row,col].nil?
        end
        unless invalid_cell_list.empty? then
          msg = "A row with a blank output cell should be completely blank.\n" +
            "The cells with invalid values have been colored red."
          raise SheetError.new(invalid_cell_list), msg
        end
      end
    end
    return true
  end
  protected :check_blank_output_rows

  def validate_opt_column
    # Check that all Opt column cells are either empty, or valid Yes/No forms.
    invalid_cell_list = []
    cand_range.each do |row|
      val = sheet[row,opt_col]
      invalid_cell_list << Cell.new(row,opt_col) unless valid_opt_cell_value?(val)
    end
    unless invalid_cell_list.empty? then
      msg = "Opt column cells must be either blank, or\n" +
        "case-insensitive variants of {Y,YES,N,NO}."
      raise SheetError.new(invalid_cell_list), msg
    end
  end
  protected :validate_opt_column

  # Returns true if +val+ is a valid value for an OPT column cell.
  # Returns false otherwise.
  #
  # ==== Valid Cell Values
  #
  # Valid OPT cell values are case-insensitive variations on the following:
  # * +nil+
  # * "Y"
  # * "YES"
  # * "N"
  # * "NO"
  def valid_opt_cell_value?(val)
    return true if val.nil?
    return val.to_s.upcase =~ /^(Y|YES|N|NO)$/
  end

  def validate_constraint_evaluations
    # Check and convert values of violation cells
    invalid_cell_list = []
    cand_range.each do |row|
      next if sheet[row,output_col].nil? # ignore blank rows
      con_range.each do |col|
        converted_value = convert_violation_value(sheet[row,col])
        if converted_value.nil? then
          invalid_cell_list << Cell.new(row,col)
        else
          sheet[row,col] = converted_value
        end
      end
    end
    unless invalid_cell_list.empty? then
      msg = "There are invalid constraint violation values in the worksheet.\n" +
        "The cells with invalid values have been colored red.\n" +
        "Valid values are non-negative integers, empty cells (no spaces), and asterisk strings."
      raise SheetError.new(invalid_cell_list), msg
    end
    return true
  end
  protected :validate_constraint_evaluations

  # Converts the value of +cell_value+ to an integer. Returns nil if
  # +cell_value+ is not a valid constraint violation cell value.
  # * nil is converted to 0 (indicating no violations)
  # * A pure star (asterisk) string is converted to a number equal to
  #   the number of stars.
  # * A non-negative numeric value is converted to an integer if it is
  #   equivalent in value to (within Float:EPSILON of) that integer.
  def convert_violation_value(cell_value)
    return 0 if cell_value.nil?  # empty cells represent zero violations
    return cell_value.length if cell_value =~ /^(\*)+$/ # convert stars to int
    begin
      float_val = Float(cell_value) # convert number or string to float
    rescue ArgumentError
      return nil # cell_value not interpretable as numeric
    end
    return nil if float_val < 0
    int_val = float_val.to_i
    return int_val if (float_val - int_val).abs <= Float::EPSILON
    return nil
  end

  # Returns true of the VT is already numbered, and false if it is not.
  def user_numbered?
    !number_col.nil?
  end

  def construct_competition_list
    @competition_list = Competition_list.new
    # Get the constraints from the column headings
    extract_constraints
    # Construct a candidate for each candidate row
    competition = Competition.new
    input_form = sheet[first_cand_row,input_col] # need to define variables outside the block for persistency.
    cand_range.each do |row|
      # Skip the row if it is empty (has no listed output)
      next if sheet[row,output_col].nil?
      # If a new input is found, close one competition and start the next one.
      if sheet[row,input_col] && (sheet[row,input_col] != input_form)
        input_form = sheet[row,input_col] # update the input
        competition_list << competition # add the previous competition to the list
        competition = Competition.new # start a new competition
      end
      # Create a candidate for the current row
      cand = Candidate.new(input_form, sheet[row,output_col],
        sheet[row,opt_col], self.constraints)
      cand.label = sheet[row,number_col] if user_numbered?
      con_range.each do |col|
        cand.set_viols(self.constraints[col-first_con_col], sheet[row,col])
      end
      cand.remark = (sheet[row,remark_col]).to_s
      competition.push(cand)
    end
    competition_list << competition # add the final competition to the list
    competition_list.auto_number_candidates unless user_numbered?
    return competition_list
  end
  protected :construct_competition_list

  def construct_image
    constraints = competition_list.constraint_list
    # Heading row
    sheet[heading_row,number_col] = "Cand\#"
    sheet[heading_row,input_col] = "Input"
    sheet[heading_row,output_col] = "Output"
    sheet[heading_row,opt_col] = "Opt"
    self.last_con_col = first_con_col - 1
    constraints.each do |con|
      self.last_con_col += 1
      sheet[heading_row,last_con_col] = con.to_s
    end
    sheet[heading_row,remark_col] = "Remarks"
    # Candidate rows
    @last_cand_row = first_cand_row - 1
    competition_list.each do |comp|
      comp.each do |cand|
        @last_cand_row += 1
        cand.to_a.each_with_index { |el,idx| sheet[last_cand_row,idx+1] = el }
      end
    end
    return true
  end
  protected :construct_image

  def construct_formatting
    # Set the number format to text for the label column
    label_range = CellRange.new(ROW1,number_col,row_count,number_col)
    add_formatting(TextFormat.new(label_range,:text))
    # format the tableau
    construct_tableau_formatting
    # Add horizontal lines separating the competitions
    hl_row_count = heading_row
    competition_list.each do |comp|
      hl_row_count += comp.size
      end_of_comp_range = CellRange.new(hl_row_count,COL1,hl_row_count,last_con_col)
      add_formatting(BorderWeight.new(end_of_comp_range, :medium, :bottom))
    end
  end
  protected :construct_formatting

end # class VT_image

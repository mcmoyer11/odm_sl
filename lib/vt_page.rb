# Author: Bruce Tesar
#

require_relative 'page'
require_relative 'vt_image'
require_relative 'constraint'
require_relative 'candidate'
require_relative 'competition'
require_relative 'competition_list'
require_relative 'sheet_error'
require_relative 'cell'
require_relative 'sheet'
require_relative 'formatting'

# A Violation Tableau page, providing an interface between
# a competition list and a session page containing a VT.
class VT_page < Page

  include Formatting
  
  # A list of the competitions of candidates in the VT.
  attr_reader :competition_list

  # The first row of the embedded VT image.
  VT_ROW_FIRST = 2 #:nodoc:

  # The first column of the embedded VT image.
  VT_COL_FIRST = 1 #:nodoc:

  # The first cell (upper lefthand corner) of the embedded VT image.
  VT_FIRST_CELL = Cell.new(VT_ROW_FIRST, VT_COL_FIRST) #:nodoc:

  # Constructs a new VT_page from either a raw sheet image or a competition list.
  # The parameter must be a hash with a key/value pair for one of two keys:
  # * :sheet key should map to a sheet containing an image of the page
  # * :competition_list key should map to a competition list
  # Whichever key is present in the hash determines the basis for the VT_page.
  # Raises ArgumentError if neither key is present.
  # When constructing from a sheet image, raises SheetError.
  def initialize(arg_hash)
    if arg_hash.has_key?(:sheet) then
      self.sheet = arg_hash[:sheet]
      validate
      construct_competition_list
    elsif arg_hash.has_key?(:competition_list) then
      @competition_list = arg_hash[:competition_list]
      self.project_name = @competition_list.label
      self.status_stamp = "VT"
      self.sheet = Sheet.new
      construct_image
      construct_formatting
    else
      msg = "VT_sheet.new must receive a hash with either :sheet or :competition_list"
      raise ArgumentError, msg
    end
  end

  # Returns the page's row index of the first row containing a candidate.
  def first_cand_row
    Cell.translate_row(@vt_image.first_cand_row, VT_ROW_FIRST)
  end

  # Returns the page's row index of the last row containing a candidate.
  def last_cand_row
    Cell.translate_row(@vt_image.last_cand_row, VT_ROW_FIRST)
  end

  # Returns the page's column index of the first column containing a constraint.
  def first_con_col
    Cell.translate_row(@vt_image.first_con_col, VT_COL_FIRST)
  end

  # Returns the page's column index of the last column containing a constraint.
  def last_con_col
    Cell.translate_row(@vt_image.last_con_col, VT_COL_FIRST)
  end

  # Returns the range of page row indices for the rows containing candidates.
  def cand_range
    (first_cand_row..last_cand_row)
  end

  # Returns the range of page column indices for the columns containing
  # constraints.
  def con_range
    (first_con_col..last_con_col)
  end

  # Returns the column index of the column containing candidate numbers.
  def number_col
    Cell.translate_row(@vt_image.number_col, VT_COL_FIRST)
  end

  # Returns the column index of the column containing candidate outputs.
  def output_col
    Cell.translate_row(@vt_image.output_col, VT_COL_FIRST)
  end

  # Returns the suffix of the status stamp for the sheet (a string).
  def status_suffix
    return /\.(.+)$/.match(status_stamp)[1]
  end

  # Returns the page name (a string) that is associated with this
  # worksheet: <project_name>.<status_suffix>
  #--
  # The page_name attribute is set here because it depends on the
  # status suffix, which depends on the status_stamp, which may
  # be reset by subclasses after the constructor has finished.
  def page_name
    self.page_name = "#{project_name}.#{status_suffix}"
  end

  # Returns true if the status_suffix of this page is .ini.
  def ini?
    return status_suffix == "ini"
  end

  # Returns true if the sheet is a valid VT.
  # If the sheet is not a valid VT, raises an appropriate exception.
  # Raises: SheetError
  def validate
    # Set identifying variables
    self.project_name = sheet.get_cell(PNAME_CELL)
    self.status_stamp = sheet.get_cell(STATUS_CELL)
    # Construct the ct_image, validating that region in the process
    tableau_range =
      CellRange.new(VT_ROW_FIRST, VT_COL_FIRST, row_count, col_count)
    tableau_image = sheet.get_range(tableau_range)
    begin
      @vt_image = VT_image.new({:sheet=>tableau_image})
    rescue SheetError => exception
      # Translate each of the invalid cells from tableau coordinates to
      # page coordinates
      translated_cells = exception.invalid_cells.map do |cell|
        cell.translate(VT_FIRST_CELL)
      end
      raise SheetError.new(translated_cells), exception.to_s
    end
    return true
  end
  protected :validate

  # Returns true of the VT is already numbered, and false if it is not.
  def user_numbered?
    @vt_image.user_numbered?
  end

  # Extracts the violation tableau data from the VT,
  # and returns a competition list.
  def construct_competition_list()
    @competition_list = @vt_image.competition_list
    @competition_list.label = project_name
    return @competition_list
  end
  protected :construct_competition_list
  
  def construct_image
    sheet.put_cell(PNAME_CELL, project_name)
    sheet.put_cell(STATUS_CELL, status_stamp)
    # construct the vt_image, and add it to the page sheet
    @vt_image = VT_image.new({:competition_list=>competition_list})
    sheet.put_range(VT_FIRST_CELL, @vt_image.sheet)
    return true
  end
  protected :construct_image

  def construct_formatting
    project_name_formatting.each {|cmd| add_formatting(cmd)}
    status_stamp_formatting.each {|cmd| add_formatting(cmd)}
    # set vertical alignment to top for the entire page
    page_range = CellRange.new(1,1,row_count,col_count)
    add_formatting(VerticalAlignment.new(page_range, :top))
    # Translate and add the VT image formatting. Duplicate the commands
    # first, so that the originals (in @vt_image) aren't affected by
    # range translation.
    image_fmt_list = @vt_image.formatting.map{|cmd| cmd.dup}
    image_fmt_list.each {|cmd| cmd.range = cmd.range.translate(VT_FIRST_CELL)}
    image_fmt_list.each {|cmd| add_formatting(cmd)}
  end
  protected :construct_formatting

end # class VT_page

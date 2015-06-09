# Author: Bruce Tesar
# 

require_relative 'cell'
require_relative 'formatting'

# This is an "abstract" class, defining some basic resources that
# are shared by the page classes, including fields for project name
# and status stamp, the location (reserved cell) for the project name
# and the status stamp, and other useful things.
class Page

  # The address of the cell containing the project name.
  PNAME_CELL = Cell.new(1,1)

  # The address of the cell containing the status stamp.
  STATUS_CELL = Cell.new(1,2)

  # The project name string of the page.
  attr_accessor :project_name

  # The status stamp string of the page.
  attr_accessor :status_stamp

  # The name string of the page (usually appears in the page tab).
  attr_accessor :page_name

  # The sheet object representing the page image.
  attr_accessor :sheet

  # Returns a new Page object (currently initializes nothing).
  def initialize
  end

  # Returns the number of rows currently in the sheet.
  def row_count
    sheet.row_count
  end

  # Returns the number of columns currently in the sheet.
  def col_count
    sheet.col_count
  end

  # Sets the project_name attribute, and writes the project name
  # to the appropriate cell in the sheet.
  def set_project_name(pname)
    self.project_name = pname
    sheet.put_cell(PNAME_CELL, pname) unless sheet.nil?
  end

  # Sets the status_stamp attribute, and writes the status stamp string
  # to the appropriate cell in the sheet.
  def set_status_stamp(stamp_string)
    self.status_stamp = stamp_string
    sheet.put_cell(STATUS_CELL, stamp_string) unless sheet.nil?
  end

  # Returns a list of formatting commands describing the standard formatting
  # for the project name cell. Class method version.
  def Page.project_name_format
    formatting_list = []
    formatting_list << Formatting::TextBold.new(PNAME_CELL.to_cellrange,true)
    return formatting_list
  end

  # Returns a list of formatting commands describing the standard formatting
  # for the project name cell. Instance method version.
  def project_name_formatting
    Page.project_name_format
  end

  # Returns a list of formatting commands describing the standard formatting
  # for the status stamp cell. Class method version.
  def Page.status_stamp_format
    formatting_list = []
    ss_range = STATUS_CELL.to_cellrange
    formatting_list << Formatting::TextBold.new(ss_range,true)
    formatting_list << Formatting::TextColor.new(ss_range,:lightviolet)
    formatting_list << Formatting::TextItalic.new(ss_range,true)
    formatting_list << Formatting::TextSize.new(ss_range,9)
    formatting_list << Formatting::HorizontalAlignment.new(ss_range, :center)
    return formatting_list
  end

  # Returns a list of formatting commands describing the standard formatting
  # for the status stamp cell. Instance method version.
  def status_stamp_formatting
    Page.status_stamp_format
  end

end # class Page

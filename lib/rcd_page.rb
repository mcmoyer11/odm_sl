# Author: Bruce Tesar
#

require_relative 'rcd_image'
require_relative 'page'
require_relative 'cell'
require_relative 'cellrange'

# This class represents a page containing the results of RCD.
# It serves as an interface between
# an internal representation of RCD results and a representation
# in a spreadsheet-like format. An instance of an +RCD_page+ contains
# both forms: an internal representation as an +Rcd+ object,
# and a two-dimensional page.
#
# The constructor for this class, +RCD_page.new+, must be given an Rcd object,
# from which it constructs the sheet image.
class RCD_page < Page

  include Formatting

  # The Rcd results object
  attr_reader :rcd_result

  # Constants describing an RCD sheet image
  CT_ROW_FIRST = 2 #:nodoc:
  CT_COL_FIRST = 1 #:nodoc:
  CT_FIRST_CELL = Cell.new(CT_ROW_FIRST, CT_COL_FIRST) #:nodoc:

  # Constructs a new RCD_page from an Rcd object.
  #
  # ==== Parameters
  #
  # The parameter +arg_hash+ must be a hash with key/value pairs.
  # The hash key +:rcd+ must be defined.
  # * +:rcd+ - a +Rcd+ object (results of RCD execution).
  #
  # ==== Exceptions
  #
  # * ArgumentError if adequate keys are not present.
  #
  # ==== Examples
  #
  #   RCD_page.new({:rcd=>rcd_result})
  #
  def initialize(arg_hash)
    # process the method parameter
    if arg_hash.has_key?(:rcd) then
      @rcd_result = arg_hash[:rcd]
    else
      msg = "RCD_page.new must receive a hash with the :rcd key defined."
      raise ArgumentError, msg
    end
    self.sheet = Sheet.new
    construct_image
    construct_formatting
  end

  def construct_image
    # First row, with project name and status stamp
    set_project_name(@rcd_result.label)
    set_status_stamp("RCD")

    self.page_name = "#{project_name}.RCD"

    # construct the RCD tableau and add it to the page sheet
    @rcd_image = RCD_image.new({:rcd=>@rcd_result})
    sheet.put_range(CT_FIRST_CELL, @rcd_image.sheet)

    # If inconsistent, add an extra row with a fail indicator.
    sheet[sheet.row_count+1,CT_COL_FIRST] = "FAIL!" unless @rcd_result.consistent?
  end
  protected :construct_image

  def construct_formatting
    project_name_formatting.each {|cmd| add_formatting(cmd)}
    status_stamp_formatting.each {|cmd| add_formatting(cmd)}

    # Translate and add the RCD image formatting
    image_fmt_list = @rcd_image.formatting.map{|cmd| cmd.dup}
    image_fmt_list.each {|cmd| cmd.range = cmd.range.translate(CT_FIRST_CELL)}
    image_fmt_list.each {|cmd| add_formatting(cmd)}

    # set vertical alignment to top for the entire page
    page_range = CellRange.new(1,1,row_count,col_count)
    add_formatting(VerticalAlignment.new(page_range, :top))

    # Extra formatting if the data were inconsistent
    unless rcd_result.consistent? then
      fail_cell = CellRange.new(row_count,CT_COL_FIRST,row_count,CT_COL_FIRST)
      add_formatting(CellColor.new(fail_cell, :red))
    end
  end
  protected :construct_formatting

end # class RCD_page

# Author: Bruce Tesar
# 

require_relative 'cell'
require_relative 'cellrange'

# A 2D rectangular grid of cells, addressed by row and column using
# count indexing (starting from 1).
class Sheet

  # The number of rows in the sheet.
  attr_reader :row_count

  # The number of columns in the sheet.
  attr_reader :col_count

  ONE_CELL_RANGE = CellRange.new(1, 1, 1, 1) #:nodoc:

  # Returns a sheet with only one cell, which contains the value nil.
  def initialize
    @row_count = 1
    @col_count = 1
    @image = [[nil]]
  end

  # Returns a new sheet with dimensions the same as array +ar+, with
  # the value of each cell of the sheet set to the value of the
  # corresponding (by indices) element of +ar+.
  def Sheet.new_from_a(ar)
    return Sheet.new if ar.nil?
    row_count = ar.size
    col_count = ar[0].size
    sheet = Sheet.new
    (1..row_count).each do |row|
      (1..col_count).each do |col|
        sheet[row,col] = ar[row-1][col-1]
      end
    end
    return sheet
  end

  # Returns an array form of the sheet, with each element of the array
  # having the same value as the corresponding cell of the sheet.
  def to_a
    @image
  end

  # Returns the value of the sheet cell at row +row+ and column +col+.
  def [](row,col)
    return nil if row>row_count || col>col_count
    @image[row-1][col-1]
  end

  # Sets the value of the sheet cell at row +row+ and column +col+ to
  # be +value+.
  def []=(row,col,value)
    extend_bounds(Cell.new(row, col), ONE_CELL_RANGE)
    @image[row-1][col-1] = value
  end

  # Returns the value of the cell at the address stored in +cell+.
  def get_cell(cell)
    return nil if cell.row>row_count || cell.col>col_count
    @image[cell.row-1][cell.col-1]
  end

  # Sets the value of the cell at the address stored in +cell+ to be +value+.
  def put_cell(cell, value)
    extend_bounds(Cell.new(cell.row, cell.col), ONE_CELL_RANGE)
    @image[cell.row-1][cell.col-1] = value
  end

  # Returns a Sheet containing the content of the range +source_range+ of self.
  # The first cell of the returned sheet contains the contents of
  # the first cell of +source_range+ in self, and so forth.
  # The returned sheet contains references to the same objects as
  # self's original image range.
  # If +source_range+ goes beyond the bounds of self, the out-of-bounds cells
  # in the returned sheet will contain nil.
  def get_range(source_range)
    # Create a new Sheet, to be filled with the values of the source_range in self.
    target = Sheet.new
    # Iterate over the range in the source (self), putting the values into the target.
    cell_first = Cell.new(source_range.row_first, source_range.col_first)
    source_range.each do |cell|
      source_value = self.get_cell(cell)
      target_cell = Sheet.relative_to_cell(cell,cell_first)
      target.put_cell(target_cell, source_value)
    end
    return target
  end

  # Replaces the values in +self+ of the range starting in +cell_first+ with
  # the corresponding values in +source+.
  # 
  # If the size of +source+ is such that it would exceed the existing
  # bounds of +self+, then +self+ is first expanded with additional rows
  # and/or columns to accommodate (new cells are initialized to nil).
  # 
  # Returns +source+.
  def put_range(cell_first, source)
    extend_bounds(cell_first, source)
    # Iterate over the source, putting the values into the range in the target (self).
    source_range = CellRange.new(1,1,source.row_count,source.col_count)
    source_range.each do |cell|
      source_value = source.get_cell(cell)
      target_cell = Sheet.translate_cell(cell, cell_first)
      self.put_cell(target_cell, source_value)
    end
    return source
  end
  
  # This method should be invoked as follows:
  # 
  #   put_range_to_index[+row+, +col+] = +source+
  # 
  # It replaces the values in +self+ of the range starting in the cell at
  # position [+row+,+col+], replacing them with the corresponding values
  # in +source+.
  #---
  # This bit of "syntactic sugar", appearing to use []= on a named method,
  # is accomplished by using an inner class, BlockAssign. The method
  # #put_range_to_index returns a new instance of BlockAssign, initialized
  # with a reference to the parent object. That instance of BlockAssign
  # defines a method []=, taking two inner parameters (inside the square
  # brackets) specifying row and column, and one outer parameter (after the
  # '=') specifying the source sheet to be put. The []= method then
  # implements the method, making calls to the parent object via the
  # contained reference.
  def put_range_to_index
    return BlockAssign.new(self)
  end
  
  # This is an "inner class", and should not be called or used externally.
  #---
  # This class is used to achieve the "syntactic sugar" provided by the
  # #put_range_to_index method.
  class BlockAssign
    def initialize(parent)
      @parent = parent
    end
    def []=(row,col,source)
      cell_first = Cell.new(row, col)
      @parent.put_range(cell_first, source)
    end
  end
  
  # Returns true if every cell in the sheet contains nil. Returns false
  # otherwise.
  def all_nil?
    sheet_range = CellRange.new(1,1,row_count,col_count)
    sheet_range.all? {|cell| get_cell(cell).nil?}
  end
  
  # Converts each cell containing nil to a cell containing a string with
  # a single blank character, " ".
  def nil_to_blank!
    sheet_range = CellRange.new(1,1,row_count,col_count)
    sheet_range.each do |cell|
      if get_cell(cell).nil? then
        put_cell(cell, " ")
      end
    end
  end

  #*********************
  #*** Class Methods ***
  #*********************

  # Returns the translation of +cell+ relative to +ref_cell+.
  # If the original frame of reference for +cell+ (starting at row 1, col 1)
  # was inserted into a new frame of reference so that the original started
  # at +ref_cell+ in the new frame, then +cell+ of the original frame would
  # correspond, in the new frame, to the cell returned by this method.
  # 
  # This is useful for translating cells when one sheet is embedded somewhere
  # within another sheet; +ref_cell+ is the beginning of the range in the
  # new sheet where the original sheet is being embedded.
  #
  # Sheet.translate_cell() is the reverse of Sheet.relative_to_cell().
  #---
  # Because sheets start their indexing from 1, the translation of a cell
  # is accomplished with the formula (for both row and col) of
  #   cell + ref_cell - 1
  # The translation of cell (2,3) w.r.t. cell (5,2) is (6,4).
  def Sheet.translate_cell(cell, ref_cell)
    Cell.new(cell.row + ref_cell.row - 1,
             cell.col + ref_cell.col - 1)
  end

  # Returns the address of +cell+ relative to +ref_cell+
  # If, within the original frame of reference for +cell+ (starting at
  # row 1, col 1), a new frame of reference were extracted starting at
  # +ref_cell+ of the original frame,  then +cell+ of the original frame
  # would correspond, in the new frame, to the cell returned by this method.
  #
  # This is useful when a range is being extracted from an original sheet
  # to form its own sheet. +ref_cell+ is the first cell in the original
  # sheet where the range is being extracted from.
  # 
  # Sheet.relative_to_cell() is the reverse of Sheet.translate_cell().
  #---
  # Because sheets start their indexing from 1, the location of a cell
  # relative to a ref cell is accomplished with the formula (for both row and
  # col) of
  #   cell - ref_cell + 1
  # The location of cell (3,4) relative to cell (2,3) is (2,2),
  def Sheet.relative_to_cell(cell, ref_cell)
    Cell.new(cell.row - ref_cell.row + 1,
             cell.col - ref_cell.col + 1)
  end

  #***********************
  #*** Private Methods ***
  #***********************
  
  def extend_bounds(start_cell, range_image)
    row_last = start_cell.row + range_image.row_count - 1
    col_last = start_cell.col + range_image.col_count - 1
    extra_rows = row_last - row_count
    add_rows(extra_rows) if extra_rows > 0
    extra_cols = col_last - col_count
    add_cols(extra_cols) if extra_cols > 0
    return (extra_rows>0) || (extra_cols>0)
  end
  private :extend_bounds

  def add_rows(num)
    num.times do
      new_row = []
      col_count.times {new_row << nil}
      @image << new_row
    end
    @row_count += num
  end
  private :add_rows

  def add_cols(num)
    @image.each do |row|
      num.times {row << nil}
    end
    @col_count += num
  end
  private :add_cols

end # class Sheet

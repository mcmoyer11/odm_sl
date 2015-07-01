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
      target_cell = cell.relative_to(cell_first)
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
      target_cell = cell.translate(cell_first)
      self.put_cell(target_cell, source_value)
    end
    return source
  end

  # Returns true if every cell in the sheet contains nil. Returns false
  # otherwise.
  def all_nil?
    sheet_range = CellRange.new(1,1,row_count,col_count)
    sheet_range.all? {|cell| get_cell(cell).nil?}
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

# Author: Bruce Tesar
# 

# An address of a range of cells in a two-dimensional sheet.
# IMPORTANT: this is *not* a collection of actual cells, only
# a coordinate-based indication of a cell range, containing first row and
# column values, and last row and column values.
class CellRange

  include Enumerable
  
  # The first row of the range.
  attr_accessor :row_first

  # The first column of the range.
  attr_accessor :col_first

  # The last row of the range.
  attr_accessor :row_last

  # The last column of the range.
  attr_accessor :col_last

  # Returns a CellRange, given the first row/column values and
  # the last row/column values.
  def initialize(row_first, col_first, row_last, col_last)
    @row_first = row_first
    @col_first = col_first
    @row_last = row_last
    @col_last = col_last
  end

  # Returns a CellRange that extends from +cell_first+ to +cell_last+.
  def CellRange.new_from_cells(cell_first, cell_last)
    return CellRange.new(cell_first.row, cell_first.col, cell_last.row, cell_last.col)
  end

  def eql?(other_range)
    return false unless row_first.eql?(other_range.row_first)
    return false unless col_first.eql?(other_range.col_first)
    return false unless row_last.eql?(other_range.row_last)
    return false unless col_last.eql?(other_range.col_last)
    return true
  end

  def ==(other_range)
    eql?(other_range)
  end

  # Returns the number of rows in the range.
  def row_count
    row_last - row_first + 1
  end

  # Returns the number of columns in the range.
  def col_count
    col_last - col_first + 1
  end

  # Returns the first cell of the range (top-left corner cell address).
  def cell_first
    return Cell.new(row_first,col_first)
  end

  # Returns the last cell of the range (bottom-right corner cell address).
  def cell_last
    return Cell.new(row_last,col_last)
  end

  # Yields a Cell for each element in the cellrange, starting with the
  # first cell, and proceeding across each row, from first row to last,
  # ending at the last cell.
  def each
    (@row_first..@row_last).each do |row|
      (@col_first..@col_last).each do |col|
        yield Cell.new(row,col)
      end
    end
  end

end # class CellRange

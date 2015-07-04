# Author: Bruce Tesar
# 

require_relative 'cellrange'

# An address of a cell in a two-dimensional sheet. IMPORTANT: this is *not*
# a complete functioning cell, only a coordinate-based address of a cell,
# containing row and column values.
class Cell

  # The row value for the cell
  attr_accessor :row

  # The column value for the cell
  attr_accessor :col

  # Returns a Cell with row +row+ and column +col+.
  def initialize(row, col)
    @row = row
    @col = col
  end

  # Returns a CellRange object representing the range consisting of
  # the single cell represented by self.
  def to_cellrange
    return CellRange.new_from_cells(self,self)
  end

  # Returns true if +cell+ has the same row and column indices
  # as self.
  def eql?(cell)
    return false unless row==cell.row
    return false unless col==cell.col
    return true
  end

  # A synonym for .eql?().
  def ==(cell)
    eql?(cell)
  end
end

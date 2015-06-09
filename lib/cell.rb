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

  # Returns the translation of row index +row+ relative to +ref_row+.
  # If a frame of reference starting at row 1 were moved so that it started
  # at row +ref_row+, then row +row+ of the original frame of reference
  # would correspond, in the new frame of reference, to the row returned
  # by this method.
  def Cell.translate_row(row, ref_row)
    ref_row + row - 1
  end

  # Returns the translation of column index +col+ relative to +ref_col+.
  # If a frame of reference starting at column 1 were moved so that it started
  # at column +ref_col+, then column +col+ of the original frame of reference
  # would correspond, in the new frame of reference, to the column returned
  # by this method.
  def Cell.translate_col(col, ref_col)
    ref_col + col - 1
  end

  # Returns the translation of self relative to the translation
  # of the original first cell (1,1) to +ref_cell+.
  # This is useful for translating cells when one sheet is embedded somewhere
  # within another sheet; +ref_cell+ is the beginning of the range in the
  # larger sheet where the smaller sheet is being embedded.
  #
  # Cell#translate() is the inverse of Cell#relative_to().
  def translate(ref_cell)
#    Cell.new(ref_cell.row+self.row-1, ref_cell.col+self.col-1)
    Cell.new(Cell.translate_row(self.row,ref_cell.row),
             Cell.translate_col(self.col,ref_cell.col))
  end

  # Returns the address of self relative to +ref_cell+, that is, adopting
  # a frame of reference where +ref_cell+ is the first cell.
  #
  # Cell#relative_to() is the inverse of Cell#translate().
  def relative_to(ref_cell)
    Cell.new(self.row-ref_cell.row+1, self.col-ref_cell.col+1)
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

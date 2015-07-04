# Author: Bruce Tesar

require 'sheet'

describe Sheet do
  context "A newly created sheet" do
    before(:each) do
      @sheet = Sheet.new
    end

    it "contains 1 row" do
      expect(@sheet.row_count).to eq(1)
    end

    it "contains 1 column" do
      expect(@sheet.col_count).to eq(1)
    end

    it "contains one empty cell" do
      expect(@sheet[1,1]).to be nil
    end
    
    # return nil for a cell outside the current sheet range
    it "returns nil for cell(2,3)" do
      cell = instance_double("Cell", :row => 2, :col => 3)
      expect(@sheet.get_cell(cell)).to be nil
    end
    
    it "contains all nil values" do
      expect(@sheet.all_nil?).to be true
    end

    it "has nil in cell(1,1)" do
      # Mock an object of class Cell, returning 1 for #row, and 1 for #col.
      # The instance_double method takes the first parameter as the name
      # of the class being mocked (here, Cell), and checks that the methods
      # being stubbed (here, #row and #col) are actually implemented in
      # the class being mocked.
      cell = instance_double("Cell", :row => 1, :col => 1)
      expect(@sheet.get_cell(cell)).to be nil
    end

    context "with [3,2] = 'stuff'" do
      before(:each) do
        @sheet[3,2] = 'stuff'
      end
      
      it "contains 3 rows" do
        expect(@sheet.row_count).to eq(3)
      end
      
      it "contains 2 columns" do
        expect(@sheet.col_count).to eq(2)
      end
      
      it "has nil in [1,1]" do
        expect(@sheet[1,1]).to be nil
      end
      
      it "does not have nil in [3,2]" do
        expect(@sheet[3,2]).not_to be nil
      end
      
      it "has value 'stuff' in [3,2]" do
        expect(@sheet[3,2]).to eq('stuff')
      end
    
      it "does not contain all nil values" do
        expect(@sheet.all_nil?).to be false
      end
      
      it "has value 'stuff' in cell(3,2)" do
        cell = instance_double("Cell", :row => 3, :col => 2)
        expect(@sheet.get_cell(cell)).to eq('stuff')
      end
      
      it "has nil in cell(1,1)" do
        cell = instance_double("Cell", :row => 1, :col => 1)
        expect(@sheet.get_cell(cell)).to be nil
      end
    end
    
    context "with value 'stuff' put to cell (3,2)" do
      before(:each) do
        @cell = instance_double("Cell", :row => 3, :col => 2)
        @sheet.put_cell(@cell,'stuff')
      end

      it "contains 3 rows" do
        expect(@sheet.row_count).to eq(3)
      end
      
      it "contains 2 columns" do
        expect(@sheet.col_count).to eq(2)
      end
      
      it "has nil in [1,1]" do
        expect(@sheet[1,1]).to be nil
      end
      
      it "does not have nil in [3,2]" do
        expect(@sheet[3,2]).not_to be nil
      end
      
      it "has value 'stuff' in [3,2]" do
        expect(@sheet[3,2]).to eq('stuff')
      end
    
      it "does not contain all nil values" do
        expect(@sheet.all_nil?).to be false
      end
    end
  end
  
  context "A sheet created from a 3x3 array with entry values 1..9" do
    before(:each) do
      @ar = [[1,2,3],[4,5,6],[7,8,9]]
      @sheet = Sheet.new_from_a(@ar)
    end
    
    it "has 3 rows" do
      expect(@sheet.row_count).to eq(3)
    end

    it "has 3 columns" do
      expect(@sheet.col_count).to eq(3)
    end

    it "has value 1 in [1,1]" do
      expect(@sheet[1,1]).to eq 1
    end

    it "has value 6 in [2,3]" do
      expect(@sheet[2,3]).to eq 6
    end
    
    it "returns an array equivalent to the original" do
      expect(@sheet.to_a).to eq @ar
    end

# TODO: the Cell mocks don't currently respond to some needed msgs.
# Does this indicate that some functionality needs to be refactored
# from Cell to Sheet? #translate(), #relative_to()
# 
#    context "returns a sheet image for range(2,2,3,3)" do
#      before(:each) do
#        @sran = instance_double("CellRange", :row_first=>2, :col_first=>2,
#          :row_last=>3, :col_last=>3)
#        cell1 = instance_double("Cell", :row=>2, :col=>2)
#        cell2 = instance_double("Cell", :row=>2, :col=>3)
#        cell3 = instance_double("Cell", :row=>3, :col=>2)
#        cell4 = instance_double("Cell", :row=>3, :col=>3)
#        allow(@sran).to receive(:each).and_yield(cell1).and_yield(cell2).and_yield(cell3).and_yield(cell4)
#        @img = @sheet.get_range(@sran)
#      end
#      
#      it "with value 5 for [1,1]" do
#        expect(@img[1,1]).to eq 5
#      end
#    end
  end
  
  context "Cell (4,1)" do
    before(:each) do
      @cell = instance_double("Cell", :row => 4, :col => 1)
    end
    
    it "has a cell translation, with respect to (5,5), of (8,5)" do
      ref_cell = instance_double("Cell", :row => 5, :col => 5)
      expect(Sheet.translate_cell(@cell, ref_cell)).to eq(Cell.new(8,5))
    end
    
    it "has a cell translation, with respect to (1,1), of (4,1)" do
      ref_cell = instance_double("Cell", :row => 1, :col => 1)
      expect(Sheet.translate_cell(@cell, ref_cell)).to eq(Cell.new(4,1))
    end
    
    it "has a cell translation, with respect to (6,3), of (9,3)" do
      ref_cell = instance_double("Cell", :row => 6, :col => 3)
      expect(Sheet.translate_cell(@cell, ref_cell)).to eq(Cell.new(9,3))
    end
  end
  
  context "Sheet [[1,2],[3,4]]" do
    before(:each) do
      @sheet = Sheet.new_from_a([[1,2],[3,4]])
    end
    
    context "with sheet [[11,12],[13,14]] put with reference cell (2,1)" do
      before(:each) do
        @ref_cell = instance_double("Cell", :row => 2, :col => 1)
        @source_sheet = Sheet.new_from_a([[11,12],[13,14]])
        @sheet.put_range(@ref_cell, @source_sheet)
      end
      
      it "has value 11 at [2,1]" do
        expect(@sheet[2,1]).to eq(11)
      end
      
      it "has value 12 at [2,2]" do
        expect(@sheet[2,2]).to eq(12)
      end
      
      it "has value 13 at [3,1]" do
        expect(@sheet[3,1]).to eq(13)
      end
      
      it "has value 14 at [3,2]" do
        expect(@sheet[3,2]).to eq(14)
      end
    end
  end
end # describe Sheet

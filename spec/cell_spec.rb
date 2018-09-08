# Author: Bruce Tesar

require_relative '../lib/cell'

RSpec.describe Cell do
  context "A cell constructed for (2,3)" do
    before(:each) do
      @cell = Cell.new(2,3)
    end

    it "has row 2" do
      expect(@cell.row).to eq(2)
    end

    it "has column 3" do
      expect(@cell.col).to eq(3)
    end
    
    it "is == to another cell (2,3)" do
      expect(@cell).to eq(Cell.new(2,3))
    end
    
    it "is eql to another cell (2,3)" do
      expect(@cell).to eql(Cell.new(2,3))
    end
    
    it "is not == to a cell (2,4)" do
      expect(@cell).not_to eq(Cell.new(2,4))
    end
    
    it "produces cellrange(2,3,2,3)" do
      expect(@cell.to_cellrange).to eq(CellRange.new(2,3,2,3))
    end
  end

end # describe Cell


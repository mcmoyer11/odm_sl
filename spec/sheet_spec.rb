# Author: Bruce Tesar

require 'sheet'

describe Sheet do
  context "A newly created sheet"
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
    expect(@sheet[0,0]).to be_nil
  end

end


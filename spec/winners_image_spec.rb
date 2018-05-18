# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../lib/winners_image'

RSpec.describe Winners_image, :wp do
  before(:each) do
    @winners = []
    @winners_image = Winners_image.new(@winners)
  end

  it "should return a winners_image object" do
    expect(@winners_image.class).to equal(Winners_image)
  end
  
  context "when it is fed an empty list of winners" do
    before(:each) do
      @winners = []
      @winners_image = Winners_image.new(@winners)
    end
    it "should return an empty sheet" do
      expect(@winners_image.sheet).to be_all_nil
    end
  end
  
  context "when it is fed a special winner" do
    before(:each) do
      @winners = ["special winner"]
      @winners_image = Winners_image.new(@winners)
      @winners_sheet = @winners_image.sheet
    end
    
    it "should produce an image with one row" do
      expect(@winners_sheet.row_count).to eq(1)
    end
    
    it "should produce an image with one column" do
      expect(@winners_sheet.col_count).to eq(1)
    end
    
    it "should return a sheet with the string 'special winner' in cell [1,1]" do
      expect(@winners_sheet[1,1]).to eq("special winner")
    end
  end
  
  context "when it is fed two winners, win1 and win2" do
    before(:each) do
       @winners = ["win1","win2"]
       @winners_image = Winners_image.new(@winners)
       @winners_sheet = @winners_image.sheet
    end
    
    it "should produce an image with two rows" do
      expect(@winners_sheet.row_count).to eq(2)
    end
    
    it "should produce an image with one column" do
      expect(@winners_sheet.col_count).to eq(1)
    end
    
    it "should return a sheet with the string 'win1' in cell [1,1]" do
      expect(@winners_sheet[1,1]).to eq("win1")
    end
    
    it "should return a sheet with the string 'win2' in cell [2,1]" do
      expect(@winners_sheet[2,1]).to eq("win2")
    end
    
  end
end


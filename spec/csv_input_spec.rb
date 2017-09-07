# Author: Bruce Tesar

require 'csv_input'

project_dir = File.absolute_path(File.join(File.dirname(__FILE__),'..'))
otgeneric_fixture_dir = File.join(project_dir,'test','fixtures','otgeneric')

RSpec.fdescribe(CSV_Input, "A CSV_Input") do
  it "uses the correct project directory" do
    expect(project_dir).to eq('C:/Users/tesar/NetBeansProjects/odm_sl')
  end
  it "uses the correct fixture directory" do
    expect(otgeneric_fixture_dir).to eq('C:/Users/tesar/NetBeansProjects/odm_sl/test/fixtures/otgeneric')
  end
  context "when created with a valid CSV filename" do
    before(:example) do
      infile = File.join(otgeneric_fixture_dir,'erc_input1.csv')
      @csv_input = CSV_Input.new(infile)
    end
    it "returns an array of column headers" do
      expect(@csv_input.headers).to eq(['ERC_Label','Con1','Con2','Con3'])
    end
    it "returns an array of arrays of the data" do
      expect(@csv_input.data).to eq([['E1','W','L','W'],['E2','e','W','L']])
    end
  end
end

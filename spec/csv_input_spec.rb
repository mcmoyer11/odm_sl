# frozen_string_literal: true

# Author: Bruce Tesar

require 'csv_input'

project_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..'))
fixture_dir = File.join(project_dir, 'test', 'fixtures')

RSpec.describe 'CsvInput' do
  context 'when created with a valid CSV filename' do
    before(:example) do
      infile = File.join(fixture_dir, 'erc_input1.csv')
      @csv_input = CsvInput.new(infile)
    end
    it 'returns an array of column headers' do
      expect(@csv_input.headers).to eq(['ERC_Label', 'Con1', 'Con2', 'Con3'])
    end
    it 'returns an array of arrays of the data' do
      expect(@csv_input.data).to eq([['E1', 'W', 'L', 'W'],
                                     ['E2', 'e', 'W', 'L']])
    end
  end
end

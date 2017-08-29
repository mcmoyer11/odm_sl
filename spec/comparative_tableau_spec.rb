# Author: Bruce Tesar

require 'comparative_tableau'

RSpec.describe Comparative_tableau do
  context "with no label passed to the constructor" do
    before(:each) do
      @ct = Comparative_tableau.new()
    end
    it "returns the label 'Comparative_tableau'" do
      expect(@ct.label).to eq('Comparative_tableau')
    end
  end
end


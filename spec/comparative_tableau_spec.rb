# Author: Bruce Tesar

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
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
  context "with a label passed to the constructor" do
    before(:each) do
      @ct = Comparative_tableau.new(label: 'CTlabel')
    end
    it "returns that label" do
      expect(@ct.label).to eq('CTlabel')
    end
  end
end


# Author: Bruce Tesar

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'otlearn/grammar_test'

RSpec.describe "A GrammarTest" do
  context "given an empty list of winners" do
    before(:each) do
      @winners = []
      @hypothesis = nil
#      @grammar_test = OTLearn::GrammarTest.new(@winners, @hypothesis)
    end
    it "has no failed winners"
    it "has no success winners"
  end
end


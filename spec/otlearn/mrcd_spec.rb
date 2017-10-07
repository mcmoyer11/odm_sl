# Author: Bruce Tesar

require 'otlearn/mrcd'
require 'loserselector_by_ranking'
require 'sl/grammar'

RSpec.describe "MRCD" do
  context "with default rcd class and an empty word list" do
    before(:each) do
      @word_list = []
      @grammar = SL::Grammar.new
      selector = LoserSelector_by_ranking.new(@grammar.system)
      @mrcd = OTLearn::Mrcd.new(@word_list, @grammar, selector)
    end
    it "should not have any changes to the ranking information" do
      expect(@mrcd.any_change?).not_to be true
    end
  end
  context "with rcd class faith_low and an empty word list" do
    before(:each) do
      @word_list = []
      @grammar = SL::Grammar.new
      selector = LoserSelector_by_ranking.new(@grammar.system, rcd_class: OTLearn::RcdFaithLow)
      @mrcd = OTLearn::Mrcd.new(@word_list, @grammar, selector)
    end
    it "should not have any changes to the ranking information" do
      expect(@mrcd.any_change?).not_to be true
    end
  end

end # describe Mrcd

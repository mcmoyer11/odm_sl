# Author: Bruce Tesar

require 'otlearn/mrcd'
require 'hypothesis'
require 'loserselector_by_ranking'
require 'sl/grammar'
require_relative '../../test/helpers/quick_erc'

RSpec.describe "MRCD" do
  context "with default rcd class and an empty word list" do
    before(:each) do
      @word_list = []
      @hypothesis = Hypothesis.new(SL::Grammar.new)
      selector = LoserSelector_by_ranking.new(@hypothesis.system)
      @mrcd = OTLearn::Mrcd.new(@word_list, @hypothesis, selector)
    end
    it "should not have any changes to the hypothesis" do
      expect(@mrcd.any_change?).not_to be true
    end
  end
  context "with rcd class faith_low and an empty word list" do
    before(:each) do
      @word_list = []
      @hypothesis = Hypothesis.new(SL::Grammar.new)
      selector = LoserSelector_by_ranking.new(@hypothesis.system, OTLearn::RcdFaithLow)
      @mrcd = OTLearn::Mrcd.new(@word_list, @hypothesis, selector)
    end
    it "should not have any changes to the hypothesis" do
      expect(@mrcd.any_change?).not_to be true
    end
  end

end # describe Mrcd

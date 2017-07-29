# Author: Bruce Tesar

require 'otlearn/mrcd'
require 'hypothesis'
require 'sl/grammar'
require 'otlearn/rcd_bias_low'
require_relative '../../test/helpers/quick_erc'

RSpec.fdescribe "MRCD" do
  context "with default rcd class and an empty word list" do
    before(:each) do
      @word_list = []
      @hypothesis = Hypothesis.new(SL::Grammar.new)
      @mrcd = OTLearn::Mrcd.new(@word_list, @hypothesis)
    end
    it "should not have any changes to the hypothesis" do
      expect(@mrcd.any_change?).not_to be true
    end
  end
  context "with rcd class faith_low and an empty word list" do
    before(:each) do
      @word_list = []
      @hypothesis = Hypothesis.new(SL::Grammar.new)
      @mrcd = OTLearn::Mrcd.new(@word_list, @hypothesis, OTLearn::RcdFaithLow)
    end
    it "should not have any changes to the hypothesis" do
      expect(@mrcd.any_change?).not_to be true
    end
  end

end # describe Mrcd

# Author: Bruce Tesar

require_relative '../../lib/otlearn/mrcd'
require_relative '../../lib/loserselector_by_ranking'

RSpec.describe "MRCD", :wip do
  context "with default rcd class and an empty word list" do
    let(:sys){double('system')}
    let(:grammar){double('grammar')}
    let(:dup_grammar){double('dup_grammar')}
    before(:each) do
      @word_list = []
      allow(grammar).to receive(:dup_same_lexicon).and_return(dup_grammar)
      allow(dup_grammar).to receive(:consistent?).and_return(true)
      selector = LoserSelector_by_ranking.new(sys)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector)
    end
    it "should not have any changes to the ranking information" do
      expect(@mrcd.any_change?).not_to be true
    end
  end
  context "with rcd class faith_low and an empty word list" do
    let(:sys){double('system')}
    let(:grammar){double('grammar')}
    let(:dup_grammar){double('dup_grammar')}
    before(:each) do
      @word_list = []
      allow(grammar).to receive(:dup_same_lexicon).and_return(dup_grammar)
      allow(dup_grammar).to receive(:consistent?).and_return(true)
      selector = LoserSelector_by_ranking.new(sys, rcd_class: OTLearn::RcdFaithLow)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector)
    end
    it "should not have any changes to the ranking information" do
      expect(@mrcd.any_change?).not_to be true
    end
  end

end # describe Mrcd

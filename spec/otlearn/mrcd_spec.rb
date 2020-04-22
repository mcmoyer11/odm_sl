# Author: Bruce Tesar

require_relative '../../lib/otlearn/mrcd'
require_relative '../../lib/loserselector_by_ranking'

RSpec.describe "MRCD", :wip do
  let(:grammar){double('grammar')}
  let(:dup_grammar){double('dup_grammar')}
  let(:selector){double('selector')}
  let(:single_mrcd_class){double('single MRCD class')}
  before(:each) do
    allow(grammar).to receive(:dup_same_lexicon).and_return(dup_grammar)    
  end
  
  context "with an empty word list" do
    before(:each) do
      @word_list = []
      allow(dup_grammar).to receive(:consistent?).and_return(true)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector,
        single_mrcd_class: single_mrcd_class)
    end
    it "should not have any changes to the ranking information" do
      expect(@mrcd.any_change?).not_to be true
    end
    it "returns no new pairs" do
      expect(@mrcd.added_pairs).to be_empty
    end
  end

  context "with a single winner producing no new pairs" do
    let(:winner){double('winner')}
    let(:mrcd_single){double('mrcd_single')}
    before(:each) do
      @word_list = [winner]
      allow(single_mrcd_class).to receive(:new).and_return(mrcd_single)
      allow(mrcd_single).to receive(:added_pairs).and_return([])
      allow(dup_grammar).to receive(:consistent?).and_return(true)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector,
        single_mrcd_class: single_mrcd_class)
    end
    it "should not have any changes to the ranking information" do
      expect(@mrcd.any_change?).not_to be true
    end
    it "returns no new pairs" do
      expect(@mrcd.added_pairs).to be_empty
    end
    it "creates one mrcd_single object" do
      expect(single_mrcd_class).to have_received(:new).exactly(1).times
    end
  end

  context "with a single winner producing one new pair" do
    let(:winner){double('winner')}
    let(:mrcd_single1){double('mrcd_single1')}
    let(:mrcd_single2){double('mrcd_single2')}
    let(:new_pair){double('new WL pair')}
    before(:each) do
      @word_list = [winner]
      allow(single_mrcd_class).to receive(:new).and_return(mrcd_single1,mrcd_single2)
      allow(mrcd_single1).to receive(:added_pairs).and_return([new_pair])
      allow(mrcd_single2).to receive(:added_pairs).and_return([])
      allow(dup_grammar).to receive(:consistent?).and_return(true)
      allow(dup_grammar).to receive(:add_erc).with(new_pair)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector,
        single_mrcd_class: single_mrcd_class)
    end
    it "has changes to the ranking information" do
      expect(@mrcd.any_change?).to be true
    end
    it "returns one new pair" do
      expect(@mrcd.added_pairs.size).to eq 1
    end
    # Two mrcd objects, one for each pass through the word list (with 1 winner)
    it "creates two mrcd_single objects" do
      expect(single_mrcd_class).to have_received(:new).exactly(2).times
    end
  end

end # describe Mrcd

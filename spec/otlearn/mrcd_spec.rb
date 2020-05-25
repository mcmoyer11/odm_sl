# Author: Bruce Tesar

require 'otlearn/mrcd'
require 'loserselector_by_ranking'

RSpec.describe 'MRCD' do
  let(:grammar){double('grammar')}
  let(:dup_grammar){double('dup_grammar')}
  let(:selector){double('selector')}
  let(:single_mrcd_class){double('single MRCD class')}
  before(:each) do
    allow(grammar).to receive(:dup_same_lexicon).and_return(dup_grammar)
  end

  context 'with an empty word list' do
    before(:each) do
      @word_list = []
      allow(dup_grammar).to receive(:consistent?).and_return(true)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector,
        single_mrcd_class: single_mrcd_class)
    end
    it 'should not have any changes to the ranking information' do
      expect(@mrcd.any_change?).not_to be true
    end
    it 'returns no new pairs' do
      expect(@mrcd.added_pairs).to be_empty
    end
  end

  context 'with a single winner producing no new pairs' do
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
    it 'should not have any changes to the ranking information' do
      expect(@mrcd.any_change?).not_to be true
    end
    it 'returns no new pairs' do
      expect(@mrcd.added_pairs).to be_empty
    end
    it 'creates one mrcd_single object' do
      expect(single_mrcd_class).to have_received(:new).exactly(1).times
    end
  end

  context 'with a single winner producing one new pair' do
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
    it 'has changes to the ranking information' do
      expect(@mrcd.any_change?).to be true
    end
    it 'returns one new pair' do
      expect(@mrcd.added_pairs.size).to eq 1
    end
    # Two mrcd objects, one for each pass through the word list (with 1 winner)
    it 'creates two mrcd_single objects' do
      expect(single_mrcd_class).to have_received(:new).exactly(2).times
    end
  end

  # If any changes occur on the first pass, it should make a second
  # pass through all of the winners.
  context 'with 3 winners producing 2 new pairs' do
    let(:winner1){double('winner1')}
    let(:winner2){double('winner2')}
    let(:winner3){double('winner3')}
    let(:mrcd_single1){double('mrcd_single1')}
    let(:mrcd_single2){double('mrcd_single2')}
    let(:mrcd_single3){double('mrcd_single3')}
    let(:mrcd_single4){double('mrcd_single4')}
    let(:mrcd_single5){double('mrcd_single5')}
    let(:mrcd_single6){double('mrcd_single6')}
    let(:new_pair1){double('new WL pair 1')}
    let(:new_pair2){double('new WL pair 2')}
    before(:each) do
      @word_list = [winner1,winner2,winner3]
      allow(single_mrcd_class).to receive(:new).and_return(mrcd_single1,
        mrcd_single2,mrcd_single3,mrcd_single4,mrcd_single5,mrcd_single6)
      allow(mrcd_single1).to receive(:added_pairs).and_return([new_pair1])
      allow(mrcd_single2).to receive(:added_pairs).and_return([])
      allow(mrcd_single3).to receive(:added_pairs).and_return([new_pair2])
      allow(mrcd_single4).to receive(:added_pairs).and_return([])
      allow(mrcd_single5).to receive(:added_pairs).and_return([])
      allow(mrcd_single6).to receive(:added_pairs).and_return([])
      allow(dup_grammar).to receive(:consistent?).and_return(true)
      allow(dup_grammar).to receive(:add_erc).with(new_pair1)
      allow(dup_grammar).to receive(:add_erc).with(new_pair2)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector,
        single_mrcd_class: single_mrcd_class)
    end
    it 'has changes to the ranking information' do
      expect(@mrcd.any_change?).to be true
    end
    it 'has a consistent grammar' do
      expect(@mrcd.grammar.consistent?).to be true
    end
    it 'returns 2 new pairs' do
      expect(@mrcd.added_pairs.size).to eq 2
    end
    # 6 mrcd objects, 3 for each pass through the word list (with 3 winners)
    it 'creates 6 mrcd_single objects' do
      expect(single_mrcd_class).to have_received(:new).exactly(6).times
    end
  end

  # When a winner leads to inconsistency, MRCD should halt immediately,
  # without processing the rest of the winners, or making another pass.
  context 'with 3 winners, the second yielding inconsistency' do
    let(:winner1){double('winner1')}
    let(:winner2){double('winner2')}
    let(:winner3){double('winner3')}
    let(:mrcd_single1){double('mrcd_single1')}
    let(:mrcd_single2){double('mrcd_single2')}
    let(:new_pair1){double('new WL pair 1')}
    before(:each) do
      @word_list = [winner1,winner2,winner3]
      allow(single_mrcd_class).to receive(:new).and_return(mrcd_single1,
        mrcd_single2)
      allow(mrcd_single1).to receive(:added_pairs).and_return([new_pair1])
      allow(mrcd_single2).to receive(:added_pairs).and_return([])
      allow(dup_grammar).to receive(:consistent?).and_return(true, false, false)
      allow(dup_grammar).to receive(:add_erc).with(new_pair1)
      @mrcd = OTLearn::Mrcd.new(@word_list, grammar, selector,
        single_mrcd_class: single_mrcd_class)
    end
    it 'has changes to the ranking information' do
      expect(@mrcd.any_change?).to be true
    end
    it 'has an inconsistent grammar' do
      expect(@mrcd.grammar.consistent?).to be false
    end
    it 'returns 1 new pair' do
      expect(@mrcd.added_pairs.size).to eq 1
    end
    # 2 mrcd objects, for first two winners of one pass
    # Verifies that MRCD terminates as soon as inconsistency occurs.
    it 'creates 2 mrcd_single objects' do
      expect(single_mrcd_class).to have_received(:new).exactly(2).times
    end
  end

end # describe Mrcd

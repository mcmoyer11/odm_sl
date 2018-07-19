# Author: Bruce Tesar

require 'otlearn/ranking_learning'

RSpec.describe "OTLearn.ranking_learning", :wip do
  let(:word_list){double('word_list')}
  let(:grammar){double('grammar')}
  let(:loser_selector){double('loser_selector')}
  let(:mrcd_class){double('mrcd_class')}
  let(:mrcd_result){double('mrcd_result')}
  let(:new_pair){double('new_pair')}
  let(:added_pair_list){[new_pair]}
  context "given a word_list and a grammar" do
    before(:each) do
      allow(mrcd_class).to receive(:new).and_return(mrcd_result)
      allow(mrcd_result).to receive(:added_pairs).and_return(added_pair_list)
      allow(grammar).to receive(:add_erc).with(new_pair)
      @result = OTLearn.ranking_learning(word_list, grammar, loser_selector,
        mrcd_class: mrcd_class)
    end
    it "executes MRCD on the given words" do
      expect(mrcd_class).to have_received(:new).with(word_list, grammar, loser_selector)
    end
    it "adds newly constructed winner-loser pairs to the grammar" do
      expect(grammar).to have_received(:add_erc).with(new_pair)
    end
    it "returns the mrcd_result" do
      expect(@result).to eq mrcd_result
    end
  end
end # RSpec.describe OTLearn ranking learning methods

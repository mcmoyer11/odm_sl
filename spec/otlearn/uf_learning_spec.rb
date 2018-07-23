# Author: Bruce Tesar

require 'otlearn/uf_learning'

RSpec.describe "OTLearn.new_rank_info_from_feature()" do
  let(:grammar){double('grammar')}
  let(:word_list){double('word_list')}
  let(:uf_feat_inst){double('uf_feat_inst')}
  let(:learning_module){double('learning_module')}
  let(:loser_selector){double('loser_selector')}
  before(:example) do
  end
  context "given an unfaithfully realized feature" do
    let(:containing_words){double('containing_words')}
    let(:conflict_words){double('conflict_words')}
    let(:dup_conflict_words){double('dup_conflict_words')}
    let(:mrcd){double('mrcd')}
    before(:example) do
      allow(word_list).to receive(:find_all).and_return(containing_words)
      allow(containing_words).to receive(:inject).and_return(conflict_words)
      allow(conflict_words).to receive(:map).and_return(dup_conflict_words)
      allow(learning_module).to receive(:ranking_learning).and_return(mrcd)
      @mrcd_result =
        OTLearn.new_rank_info_from_feature(grammar, word_list, uf_feat_inst,
        learning_module: learning_module, loser_selector: loser_selector)
    end
    it "finds words containing that feature" do
      expect(word_list).to have_received(:find_all)
    end
    it "finds words that have a uf-output conflict on the feature" do
      expect(containing_words).to have_received(:inject)
    end
    it "duplicates and output-matches the conflict words" do
      expect(conflict_words).to have_received(:map)
    end
    it "returns the MRCD result" do
      expect(@mrcd_result).to eq mrcd
    end
  end
end # RSpec.describe UfLearning

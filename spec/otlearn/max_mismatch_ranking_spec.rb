# Author: Morgan Moyer / Bruce Tesar

require_relative '../../lib/otlearn/max_mismatch_ranking'

RSpec.describe OTLearn::MaxMismatchRanking, :wip do
  let(:failed_winner){double('failed_winner')}
  let(:failed_winner_list){[failed_winner]}
  let(:grammar){double('grammar')}
  let(:language_learner){double("language_learner").as_null_object}
  let(:ranking_learning_module){double("ranking_learning_module")}
  let(:mrcd_result){double('mrcd_result')}
  let(:mismatch){double('mismatch')}
  
  context "given a consistent failed winner that yields new ranking information" do
    let(:new_pair){double('new_pair')}
    before(:each) do
      allow(mrcd_result).to receive(:any_change?).and_return(true)
      allow(mrcd_result).to receive(:added_pairs).and_return([new_pair])
      allow(ranking_learning_module).to \
        receive(:mismatches_input_to_output).with(failed_winner).and_yield(mismatch)
      allow(ranking_learning_module).to \
        receive(:ranking_learning_mark_low_no_mod).with([mismatch], grammar).and_return(mrcd_result)
      @max_mismatch_rankings =
        OTLearn::MaxMismatchRanking.new(failed_winner_list, grammar,
        language_learner, ranking_learning_module: ranking_learning_module)
    end
    it "returns a list with the newpair" do
      expect(@max_mismatch_rankings.newly_added_wl_pairs).to eq([new_pair])
    end
    it "indicates a change has occurred" do
      expect(@max_mismatch_rankings.changed?).to be true
    end
    it "calls #ranking_learning_mark_low_mrcd" do
      expect(ranking_learning_module).to have_received(:ranking_learning_mark_low_no_mod)
    end
    it "determines the failed winner" do
      expect(@max_mismatch_rankings.failed_winner).to eq(failed_winner)
    end
  end
     
  context "when a consistent failed winner does not yield new ranking information" do
    before(:each) do
      allow(mrcd_result).to receive(:any_change?).and_return(false)
      allow(mrcd_result).to receive(:added_pairs).and_return([])
      allow(ranking_learning_module).to \
        receive(:mismatches_input_to_output).with(failed_winner).and_yield(mismatch)
      allow(ranking_learning_module).to \
        receive(:ranking_learning_mark_low_no_mod).with([mismatch],grammar).and_return(mrcd_result)
    end
    it "should raise an exception" do
      expect do
        @max_mismatch_rankings =
          OTLearn::MaxMismatchRanking.new(failed_winner_list, grammar,
          language_learner, ranking_learning_module: ranking_learning_module)
      end.to raise_error(RuntimeError)
    end
  end #context
  
end # RSpec.describe OTLearn::MaxMismatchRanking
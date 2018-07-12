# Author: Morgan Moyer / Bruce Tesar

require_relative '../../lib/otlearn/max_mismatch_ranking'

RSpec.describe OTLearn::MaxMismatchRanking, :wip do
  let(:failed_winner){double('failed_winner')}
  let(:failed_winner_list){[failed_winner]}
  let(:grammar){double('grammar')}
  let(:language_learner){double("language_learner").as_null_object}
  context "if #run is not called" do
    before(:each) do
      @max_mismatch_rankings =
        OTLearn::MaxMismatchRanking.new(failed_winner_list, grammar, language_learner)
      # dependency injection here
      @ranking_learning_module = double("ranking_learning_module")
      @max_mismatch_rankings.ranking_learning_module = @ranking_learning_module
    end
    it "returns an empty list of winner-loser pairs" do
      expect(@max_mismatch_rankings.newly_added_wl_pairs).to be_empty
    end
    it "indicates no change has occurred" do
      expect(@max_mismatch_rankings.changed?).to be false
    end     
  end #context "if #run is not called
  
  context "given a consistent failed winner that yields new ranking information" do
    before(:each) do
      # mock the parameters
      @new_pair = double('new_pair')
      @mrcd_result = double('mrcd_result')
      @mismatch = double('mismatch')
      @ranking_learning_module = double('ranking_learning_module')
      allow(@mrcd_result).to receive(:any_change?).and_return(true)
      allow(@mrcd_result).to receive(:added_pairs).and_return([@new_pair])
      # a test double of OTLearn for dependency injection
      @max_mismatch_rankings = OTLearn::MaxMismatchRanking.new(failed_winner_list,grammar,language_learner)
      @max_mismatch_rankings.ranking_learning_module = @ranking_learning_module
      # construct a consistent failed winner
      allow(@ranking_learning_module).to \
        receive(:mismatches_input_to_output).with(failed_winner).and_yield(@mismatch)
      allow(@ranking_learning_module).to \
        receive(:ranking_learning_mark_low_no_mod).with([@mismatch], grammar).and_return(@mrcd_result)
      @max_mismatch_rankings.run
    end
    it "returns a list with the newpair" do
      expect(@max_mismatch_rankings.newly_added_wl_pairs).to eq([@new_pair])
    end
    it "indicates a change has occurred" do
      expect(@max_mismatch_rankings.changed?).to be true
    end
    it "calls #ranking_learning_mark_low_mrcd" do
      expect(@ranking_learning_module).to have_received(:ranking_learning_mark_low_no_mod)
    end
    it "determines the failed winner" do
      expect(@max_mismatch_rankings.failed_winner).to eq(failed_winner)
    end
  end
     
  context "when a consistent failed winner does not yield new ranking information" do
    before(:each) do
      # mock the parameters
      @mrcd_result = double('mrcd_result')
      @mismatch = double('mismatch')
      @ranking_learning_module = double('ranking_learning_module')
      allow(@mrcd_result).to receive(:any_change?).and_return(false)
      allow(@mrcd_result).to receive(:added_pairs).and_return([])
      @max_mismatch_rankings = OTLearn::MaxMismatchRanking.new(failed_winner_list,grammar,language_learner)
      @max_mismatch_rankings.ranking_learning_module = @ranking_learning_module
      allow(@ranking_learning_module).to \
        receive(:mismatches_input_to_output).with(failed_winner).and_yield(@mismatch)
      allow(@ranking_learning_module).to \
        receive(:ranking_learning_mark_low_no_mod).with([@mismatch],grammar).and_return(@mrcd_result)
    end
    it "should raise an exception" do
      expect{@max_mismatch_rankings.run}.to raise_error(RuntimeError)
    end
  end #context
  
end # RSpec.describe OTLearn::MaxMismatchRanking
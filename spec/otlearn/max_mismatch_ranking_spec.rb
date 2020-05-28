# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/max_mismatch_ranking'

RSpec.describe OTLearn::MaxMismatchRanking do
  let(:failed_winner) { double('failed_winner') }
  let(:failed_winner_list) { [failed_winner] }
  let(:mismatch) { double('mismatch') }
  let(:grammar) { double('grammar') }
  let(:language_learner) { double('language_learner').as_null_object }
  let(:learning_module) { double('learning_module') }
  let(:loser_selector) { double('loser_selector') }
  let(:mrcd_result) { double('mrcd_result') }
  before(:example) do
    allow(failed_winner).to receive(:output)
    allow(grammar).to receive(:parse_output).and_return(mismatch)
    allow(mismatch).to receive(:mismatch_input_to_output!)
    allow(learning_module).to receive(:ranking_learning)\
      .with([mismatch], grammar, loser_selector).and_return(mrcd_result)
  end

  context 'given a consistent failed winner that yields new ranking information' do
    let(:new_pair) { double('new_pair') }
    before(:example) do
      allow(mrcd_result).to receive(:any_change?).and_return(true)
      allow(mrcd_result).to receive(:added_pairs).and_return([new_pair])
      @max_mismatch_rankings =
        OTLearn::MaxMismatchRanking\
        .new(failed_winner_list, grammar, language_learner,
             loser_selector: loser_selector,
             learning_module: learning_module)
    end
    it 'returns a list with the newpair' do
      expect(@max_mismatch_rankings.newly_added_wl_pairs).to eq([new_pair])
    end
    it 'indicates a change has occurred' do
      expect(@max_mismatch_rankings.changed?).to be true
    end
    it 'calls #ranking_learning' do
      expect(learning_module).to have_received(:ranking_learning)
    end
    it 'determines the failed winner' do
      expect(@max_mismatch_rankings.failed_winner).to eq(mismatch)
    end
  end

  context 'when a consistent failed winner does not yield new ranking information' do
    before(:example) do
      allow(mrcd_result).to receive(:any_change?).and_return(false)
    end
    it 'should raise an exception' do
      expect do
        @max_mismatch_rankings =
          OTLearn::MaxMismatchRanking\
          .new(failed_winner_list, grammar, language_learner,
               loser_selector: loser_selector,
               learning_module: learning_module)
      end.to raise_error(RuntimeError)
    end
  end
end

# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/max_mismatch_ranking'

RSpec.describe OTLearn::MaxMismatchRanking do
  let(:failed_winner) { double('failed_winner') }
  let(:failed_winner_list) { [failed_winner] }
  let(:mismatch) { double('mismatch') }
  let(:grammar) { double('grammar') }
  let(:erc_learner) { double('erc_learner') }
  let(:mrcd_result) { double('mrcd_result') }
  before(:example) do
    allow(failed_winner).to receive(:output)
    allow(grammar).to receive(:parse_output).and_return(mismatch)
    allow(mismatch).to receive(:mismatch_input_to_output!)
    allow(erc_learner).to receive(:run).and_return(mrcd_result)
  end

  context 'with a consistent failed winner yielding new ranking info' do
    let(:new_pair) { double('new_pair') }
    before(:example) do
      allow(mrcd_result).to receive(:any_change?).and_return(true)
      allow(mrcd_result).to receive(:added_pairs).and_return([new_pair])
      @max_mismatch_rankings =
        OTLearn::MaxMismatchRanking\
        .new(failed_winner_list, grammar, erc_learner: erc_learner)
    end
    it 'returns a list with the newpair' do
      expect(@max_mismatch_rankings.newly_added_wl_pairs).to eq([new_pair])
    end
    it 'indicates a change has occurred' do
      expect(@max_mismatch_rankings.changed?).to be true
    end
    it 'runs the ERC learner' do
      expect(erc_learner).to\
        have_received(:run).with([mismatch], grammar)
    end
    it 'determines the failed winner' do
      expect(@max_mismatch_rankings.failed_winner).to eq(mismatch)
    end
  end

  context 'with a consistent failed winner yielding no new ranking info' do
    before(:example) do
      allow(mrcd_result).to receive(:any_change?).and_return(false)
    end
    it 'should raise an exception' do
      expect do
        @max_mismatch_rankings =
          OTLearn::MaxMismatchRanking\
          .new(failed_winner_list, grammar, erc_learner: erc_learner)
      end.to raise_error(RuntimeError)
    end
  end
end

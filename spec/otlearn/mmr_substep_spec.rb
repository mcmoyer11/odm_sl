# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/mmr_substep'
require 'otlearn/otlearn'

RSpec.describe 'OTLearn::MmrSubstep' do
  let(:new_pairs) { double('new_pairs') }
  let(:failed_winner) { double('failed_winner') }
  let(:change_flag) { double('change_flag') }
  before(:example) do
    @substep = OTLearn::MmrSubstep.new(new_pairs, failed_winner, change_flag)
  end
  it 'indicates a subtype of MaxMismatchRanking' do
    expect(@substep.subtype).to eq OTLearn::MAX_MISMATCH_RANKING
  end
  it 'returns the list of newly added WL pairs' do
    expect(@substep.newly_added_wl_pairs).to eq new_pairs
  end
  it 'returns the failed winner' do
    expect(@substep.failed_winner).to eq failed_winner
  end
  it 'returns the grammar change flag' do
    expect(@substep.changed?).to eq change_flag
  end
end

# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'ranker'
require 'compare_pool'
require 'compare_ctie'
require 'compare_consistency'
require 'loser_selector'
require 'constraint'
require 'candidate'
require 'erc'
require 'erc_list'

MARK = Constraint::MARK
FAITH = Constraint::FAITH

RSpec.describe 'loser selection', :integration do
  before(:example) do
    rcd_ranker = Ranker.new # default of RCD
    pool_comparer = ComparePool.new(rcd_ranker)
    @pool_selector = LoserSelector.new(pool_comparer)
    ctie_comparer = CompareCtie.new(rcd_ranker)
    @ctie_selector = LoserSelector.new(ctie_comparer)
    consistency_comparer = CompareConsistency.new
    @consistency_selector = LoserSelector.new(consistency_comparer)

    @c1 = Constraint.new('c1', 1, MARK)
    @c2 = Constraint.new('c2', 2, MARK)
    @c3 = Constraint.new('c3', 3, MARK)
    @c4 = Constraint.new('c4', 4, MARK)
    @constraint_list = [@c1, @c2, @c3, @c4]

    @winner = Candidate.new('input', 'winner', @constraint_list)
    @cand1 = Candidate.new('input', 'cand1', @constraint_list)
    @cand2 = Candidate.new('input', 'cand2', @constraint_list)

    @winner.set_viols(@c1, 0)
    @winner.set_viols(@c2, 2)
    @winner.set_viols(@c3, 1)
    @winner.set_viols(@c4, 0)
    @cand1.set_viols(@c1, 0)
    @cand1.set_viols(@c2, 1)
    @cand1.set_viols(@c3, 0)
    @cand1.set_viols(@c4, 2)
    @cand2.set_viols(@c1, 1)
    @cand2.set_viols(@c2, 1)
    @cand2.set_viols(@c3, 1)
    @cand2.set_viols(@c4, 1)
  end

  context 'c1 >> c2 >> c3 >> c4' do
    before(:example) do
      erc1 = Erc.new(@constraint_list)
      erc1.set_w(@c1)
      erc1.set_l(@c2)
      erc2 = Erc.new(@constraint_list)
      erc2.set_w(@c2)
      erc2.set_l(@c3)
      erc3 = Erc.new(@constraint_list)
      erc3.set_w(@c3)
      erc3.set_l(@c4)
      @erc_list = ErcList.new.add_all([erc1, erc2, erc3])
      @competition = [@cand2, @winner, @cand1]
    end
    it 'Pool selects cand1' do
      loser = @pool_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to eq @cand1
    end
    it 'Ctie selects cand1' do
      loser = @ctie_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to eq @cand1
    end
    it 'Consistency selects cand1' do
      loser =
        @consistency_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to eq @cand1
    end
  end
  context 'c4 >> c2 >> c3 >> c1' do
    before(:example) do
      erc1 = Erc.new(@constraint_list)
      erc1.set_w(@c4)
      erc1.set_l(@c2)
      erc2 = Erc.new(@constraint_list)
      erc2.set_w(@c2)
      erc2.set_l(@c3)
      erc3 = Erc.new(@constraint_list)
      erc3.set_w(@c3)
      erc3.set_l(@c1)
      @erc_list = ErcList.new.add_all([erc1, erc2, erc3])
      @competition = [@cand2, @winner, @cand1]
    end
    it 'Pool selects no loser' do
      loser = @pool_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to be_nil
    end
    it 'Ctie selects no loser' do
      loser = @ctie_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to be_nil
    end
    it 'Consistency selects no loser' do
      loser =
        @consistency_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to be_nil
    end
  end
end

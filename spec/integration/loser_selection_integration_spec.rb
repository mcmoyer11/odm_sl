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

def assign_violations(candidate, constraint_list, violation_list)
  constraint_list.each_with_index do |con, idx|
    candidate.set_viols(con, violation_list[idx])
  end
end

def construct_erc(constraint_list, evaluation_list)
  erc = Erc.new(constraint_list)
  constraint_list.each_with_index do |con, idx|
    case evaluation_list[idx]
    when :W
      erc.set_w(con)
    when :L
      erc.set_l(con)
    end
  end
  erc
end

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
  end

  context 'total ranking with cand1 optimal' do
    before(:example) do
      erc1 = construct_erc(@constraint_list, [:W, :L, :e, :e])
      erc2 = construct_erc(@constraint_list, [:e, :W, :L, :e])
      erc3 = construct_erc(@constraint_list, [:e, :e, :W, :L])
      @erc_list = ErcList.new.add_all([erc1, erc2, erc3])
      assign_violations(@winner, @constraint_list, [0, 2, 1, 0])
      assign_violations(@cand1, @constraint_list, [0, 1, 0, 2])
      assign_violations(@cand2, @constraint_list, [1, 1, 1, 1])
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
  context 'total ranking with winner optimal' do
    before(:example) do
      erc1 = construct_erc(@constraint_list, [:W, :L, :e, :e])
      erc2 = construct_erc(@constraint_list, [:e, :W, :L, :e])
      erc3 = construct_erc(@constraint_list, [:e, :e, :W, :L])
      @erc_list = ErcList.new.add_all([erc1, erc2, erc3])
      assign_violations(@winner, @constraint_list, [0, 2, 1, 0])
      assign_violations(@cand1, @constraint_list, [2, 1, 0, 0])
      assign_violations(@cand2, @constraint_list, [1, 1, 1, 1])
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
  context 'conflicting constraints with unequal sums' do
    before(:example) do
      # Rcd will give {c1,c2} >> {c3} >> {c4}
      # c1 is only high-ranked by default
      erc1 = construct_erc(@constraint_list, [:e, :W, :L, :e])
      erc2 = construct_erc(@constraint_list, [:e, :e, :W, :L])
      @erc_list = ErcList.new.add_all([erc1, erc2])
      # winner has fewer violations of {c1,c2}, but more of {c2}
      assign_violations(@winner, @constraint_list, [0, 1, 1, 0])
      assign_violations(@cand1, @constraint_list, [2, 0, 1, 0])
      @competition = [@winner, @cand1]
    end
    it 'Pool selects no loser' do
      loser = @pool_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to be_nil
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
  context 'one competitor ident viols, the other more harmonic' do
    before(:example) do
      # Rcd will give {c1,c2} >> {c3} >> {c4}
      # c1 is only high-ranked by default
      erc1 = construct_erc(@constraint_list, [:e, :W, :L, :e])
      erc2 = construct_erc(@constraint_list, [:e, :e, :W, :L])
      @erc_list = ErcList.new.add_all([erc1, erc2])
      # winner has fewer violations of {c1,c2}, but more of {c2}
      assign_violations(@winner, @constraint_list, [0, 1, 1, 0])
      assign_violations(@cand1, @constraint_list, [0, 1, 1, 0])
      assign_violations(@cand2, @constraint_list, [0, 1, 0, 0])
      @competition = [@cand1, @winner, @cand2]
    end
    it 'Pool selects cand2' do
      loser = @pool_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to eq @cand2
    end
    it 'Ctie selects cand2' do
      loser = @ctie_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to eq @cand2
    end
    it 'Consistency selects cand2' do
      loser =
        @consistency_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to eq @cand2
    end
  end
  context 'winner harmonically bounds the competitor' do
    before(:example) do
      # Rcd will give {c1,c2,c3} >> {c4}
      # c1 is only high-ranked by default
      erc1 = construct_erc(@constraint_list, [:e, :e, :W, :L])
      @erc_list = ErcList.new.add_all([erc1])
      # winner has fewer violations of {c1,c2}, but more of {c2}
      assign_violations(@winner, @constraint_list, [0, 1, 1, 0])
      assign_violations(@cand1, @constraint_list, [0, 1, 1, 1])
      @competition = [@cand1, @winner]
    end
    it 'Pool selects no loser' do
      loser = @pool_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to be nil
    end
    it 'Ctie selects no loser' do
      loser = @ctie_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to be nil
    end
    it 'Consistency selects no loser' do
      loser =
        @consistency_selector.select_loser(@winner, @competition, @erc_list)
      expect(loser).to be nil
    end
  end
end

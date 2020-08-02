# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/consistent_value_finder'

RSpec.describe 'OTLearn::ConsistentValueFinder' do
  let(:assigner) { double('input feature assigner') }
  let(:evaluator) { double('conflict feature evaluator') }
  let(:uf_finst) { double('UF feature instance') }
  let(:uf_feat) { double('UF feature') }
  let(:word_list) { double('word list') }
  let(:conflict_features) { double('conflict features') }
  let(:grammar) { double('grammar') }
  before(:example) do
    allow(uf_finst).to receive(:feature).and_return(uf_feat)
    allow(assigner).to receive(:assign_input_features)
    @finder = OTLearn::ConsistentValueFinder.new(input_assigner: assigner)
    @finder.conflict_evaluator = evaluator
  end

  context 'given a feature with two consistent values' do
    let(:val1) { double('feature value 1') }
    let(:val2) { double('feature value 2') }
    before(:example) do
      allow(uf_feat).to receive(:each_value).and_yield(val1)\
                                            .and_yield(val2)
      allow(evaluator).to receive(:run).and_return(true, true)
      @result = @finder.run(uf_finst, word_list, conflict_features, grammar)
    end
    it 'assigns both values to the inputs' do
      expect(assigner).to\
        have_received(:assign_input_features).exactly(2).times
    end
    it 'evaluates both values' do
      expect(evaluator).to have_received(:run).exactly(2).times
    end
    it 'returns both feature values' do
      expect(@result).to contain_exactly(val1, val2)
    end
  end
  context 'given a feature with one consistent and one inconsistent value' do
    let(:val1) { double('feature value 1') }
    let(:val2) { double('feature value 2') }
    before(:example) do
      allow(uf_feat).to receive(:each_value).and_yield(val1)\
                                            .and_yield(val2)
      allow(evaluator).to receive(:run).and_return(true, false)
      @result = @finder.run(uf_finst, word_list, conflict_features, grammar)
    end
    it 'assigns both values to the inputs' do
      expect(assigner).to\
        have_received(:assign_input_features).exactly(2).times
    end
    it 'evaluates both values' do
      expect(evaluator).to have_received(:run).exactly(2).times
    end
    it 'returns the consistent value' do
      expect(@result).to contain_exactly(val1)
    end
  end
  context 'given two inconsistent values' do
    let(:val1) { double('feature value 1') }
    let(:val2) { double('feature value 2') }
    before(:example) do
      allow(uf_feat).to receive(:each_value).and_yield(val1)\
                                            .and_yield(val2)
      allow(evaluator).to receive(:run).and_return(false, false)
      @result = @finder.run(uf_finst, word_list, conflict_features, grammar)
    end
    it 'assigns both values to the inputs' do
      expect(assigner).to\
        have_received(:assign_input_features).exactly(2).times
    end
    it 'evaluates both values' do
      expect(evaluator).to have_received(:run).exactly(2).times
    end
    it 'returns an empty list' do
      expect(@result).to be_empty
    end
  end
end

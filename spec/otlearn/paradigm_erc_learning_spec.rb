# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/paradigm_erc_learning'

RSpec.describe 'OTLearn::ParadigmErcLearning' do
  let(:erc_learner) { double('erc_learner') }
  let(:word_searcher) { double('word_searcher') }
  let(:set_feature) { double('set_feature') }
  let(:grammar) { double('grammar') }
  let(:output1) { double('output1') }
  let(:word1) { double('word1') }
  let(:mword) { double('mword') }
  let(:morpheme) { double('morpheme') }
  let(:mrcd) { double('mrcd') }
  before(:example) do
    allow(set_feature).to receive(:morpheme).and_return(morpheme)
    allow(word1).to receive(:match_input_to_output!).and_return(word1)
    allow(word_searcher).to receive(:find_unfaithful)
    allow(erc_learner).to receive(:run)
    @learner = OTLearn::ParadigmErcLearning.new
    @learner.erc_learner = erc_learner
    @learner.word_searcher = word_searcher
  end

  context 'with a feature lacking unfaithful realizations' do
    before(:example) do
      allow(output1).to receive(:morphword).and_return(mword)
      allow(mword).to receive(:include?).and_return(true)
      allow(grammar).to\
        receive(:parse_output).with(output1).and_return(word1)
      allow(word_searcher).to receive(:find_unfaithful).and_return([])
      allow(erc_learner).to receive(:run).and_return(mrcd)
      allow(mrcd).to receive(:any_change?).and_return(false)
      @changed = @learner.run(set_feature, grammar, [output1])
    end
    it 'selects words containing the set feature\'s morpheme' do
      expect(mword).to have_received(:include?).with(morpheme)
    end
    it 'parses the outputs into words' do
      expect(grammar).to have_received(:parse_output).with(output1)
    end
    it 'matches unset features to their outputs' do
      expect(word1).to have_received(:match_input_to_output!)
    end
    it 'searches for words where the output mismatches the set feature' do
      expect(word_searcher).to\
        have_received(:find_unfaithful).with(set_feature, [word1])
    end
    it 'runs erc_learner' do
      expect(erc_learner).to have_received(:run)
    end
    it 'indicates no new ERCs' do
      expect(@changed).to be_falsey
    end
  end
  context 'with a feature generating no ERCs' do
    before(:example) do
      allow(output1).to receive(:morphword).and_return(mword)
      allow(mword).to receive(:include?).and_return(true)
      allow(grammar).to\
        receive(:parse_output).with(output1).and_return(word1)
      allow(word_searcher).to receive(:find_unfaithful).and_return([word1])
      allow(erc_learner).to receive(:run).and_return(mrcd)
      allow(mrcd).to receive(:any_change?).and_return(false)
      @changed = @learner.run(set_feature, grammar, [output1])
    end
    it 'selects words containing the set feature\'s morpheme' do
      expect(mword).to have_received(:include?).with(morpheme)
    end
    it 'parses the outputs into words' do
      expect(grammar).to have_received(:parse_output).with(output1)
    end
    it 'matches unset features to their outputs' do
      expect(word1).to have_received(:match_input_to_output!)
    end
    it 'searches for words where the output mismatches the set feature' do
      expect(word_searcher).to\
        have_received(:find_unfaithful).with(set_feature, [word1])
    end
    it 'runs erc_learner' do
      expect(erc_learner).to have_received(:run).with([word1], grammar)
    end
    it 'indicates no new ERCs' do
      expect(@changed).to be_falsey
    end
  end
end

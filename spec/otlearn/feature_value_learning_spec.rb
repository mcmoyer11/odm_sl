# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/feature_value_learning'

RSpec.describe 'OTLearn::FeatureValueLearning' do
  let(:grammar) { double('grammar') }
  let(:word1) { double('word1') }
  let(:out1) { double('output1') }
  let(:w1) { double('w1') }
  let(:word_search) { double('word search') }
  let(:learn_module) { double('learn_module') }
  before(:example) do
    allow(word1).to receive(:dup).and_return(w1)
    allow(w1).to receive(:sync_with_lexicon!)
    allow(w1).to receive(:match_input_to_output!)
    @learner = OTLearn::FeatureValueLearning.new(word_search: word_search,
                                                 learn_module: learn_module)
  end

  context 'with one settable feature' do
    let(:m_in_w) { double('morphemes in words hash') }
    let(:morph1) { double('morpheme1') }
    let(:morph2) { double('morpheme2') }
    let(:target_feature) { double('target_feature') }
    let(:target_value) { double('target_value') }
    before(:example) do
      words = [word1]
      allow(word_search).to receive(:morphemes_to_words).with([w1])\
                                                        .and_return(m_in_w)
      allow(m_in_w).to receive(:keys).and_return([morph1, morph2])
      allow(word_search).to receive(:find_unset_features)\
        .and_return([target_feature])
      allow(target_feature).to receive(:morpheme).and_return(morph1)
      allow(target_feature).to receive(:value=)
      allow(m_in_w).to receive(:[]).with(morph1).and_return([w1])
      allow(word_search).to receive(:conflicting_output_values?)\
        .with(target_feature, [w1]).and_return(false)
      allow(learn_module).to receive(:consistent_feature_values)\
        .with(target_feature, [w1], [], grammar).and_return([target_value])
      @set_features = @learner.run(words, grammar)
    end
    # it 'parses the output of the word' do
    #   expect(grammar).to have_received(:parse_output).with(out1)
    # end
    it 'duplicates the word' do
      expect(word1).to have_received(:dup)
    end
    it 'matches the input to the UF' do
      expect(w1).to have_received(:sync_with_lexicon!)
    end
    it 'matches unset input features to the output' do
      expect(w1).to have_received(:match_input_to_output!)
    end
    it 'checks the words for conflicting values of the target feature' do
      expect(word_search).to have_received(:conflicting_output_values?)\
        .with(target_feature, [w1])
    end
    it 'sets the feature' do
      expect(target_feature).to have_received(:value=).with(target_value)
    end
    it 'returns a list of newly set features' do
      expect(@set_features).to contain_exactly(target_feature)
    end
  end
end

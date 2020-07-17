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
    allow(word1).to receive(:output).and_return(out1)
    allow(grammar).to receive(:parse_output).with(out1).and_return(w1)
    allow(w1).to receive(:match_input_to_output!)
    @learner = OTLearn::FeatureValueLearning.new(word_search: word_search,
                                                 learn_module: learn_module)
  end

  context 'with one settable feature' do
    let(:m_in_w) { double('morphemes in words hash') }
    let(:morph1) { double('morpheme1') }
    let(:morph2) { double('morpheme2') }
    let(:target_feature) { double('target_feature') }
    before(:example) do
      words = [word1]
      allow(word_search).to receive(:morphemes_to_words).with([w1])\
                                                        .and_return(m_in_w)
      allow(m_in_w).to receive(:keys).and_return([morph1, morph2])
      allow(word_search).to receive(:find_unset_features)\
        .and_return([target_feature])
      allow(target_feature).to receive(:morpheme).and_return(morph1)
      allow(m_in_w).to receive(:[]).with(morph1).and_return([w1])
      allow(word_search).to receive(:conflicting_output_values?)\
        .with(target_feature, [w1]).and_return(false)
      allow(learn_module).to receive(:test_unset_feature)\
        .with(target_feature, [w1], [], grammar).and_return(true)
      @set_features = @learner.run(words, grammar)
    end
    it 'parses the output of the word' do
      expect(grammar).to have_received(:parse_output).with(out1)
    end
    it 'matches the input to the output' do
      expect(w1).to have_received(:match_input_to_output!)
    end
    it 'checks the words for conflicting values of the target feature' do
      expect(word_search).to have_received(:conflicting_output_values?)\
        .with(target_feature, [w1])
    end
    it 'sets the feature' do
      expect(@set_features).to contain_exactly(target_feature)
    end
  end
end

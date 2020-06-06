# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'language_generator'

RSpec.describe 'LanguageGenerator' do
  let(:eval) { double('eval') }
  let(:hier) { double('hierarchy') }
  context 'given one competition with one optimum' do
    let(:opt1) { double('optimal1') }
    let(:comp1) { double('competition1') }
    before(:example) do
      allow(eval).to receive(:find_optima).with(comp1, hier)\
                                          .and_return([opt1])
      @comp_list = [comp1]
      @generator = LanguageGenerator.new(eval)
    end
    it 'returns an array with the optimum' do
      expect(@generator.generate_language(@comp_list, hier)).to\
        contain_exactly(opt1)
    end
  end
  context 'given two competitions each with one optimum' do
    let(:opt1) { double('optimal1') }
    let(:opt2) { double('optimal2') }
    let(:comp1) { double('competition1') }
    let(:comp2) { double('competition2') }
    before(:example) do
      allow(eval).to receive(:find_optima).with(comp1, hier)\
                                          .and_return([opt1])
      allow(eval).to receive(:find_optima).with(comp2, hier)\
                                          .and_return([opt2])
      @comp_list = [comp1, comp2]
      @generator = LanguageGenerator.new(eval)
    end
    it 'returns an array with both optima' do
      expect(@generator.generate_language(@comp_list, hier)).to\
        contain_exactly(opt1, opt2)
    end
  end
  context 'given two competitions, one with one optimum and one with two' do
    let(:opt1) { double('optimal1') }
    let(:opt2a) { double('optimal2a') }
    let(:opt2b) { double('optimal2b') }
    let(:comp1) { double('competition1') }
    let(:comp2) { double('competition2') }
    before(:example) do
      allow(eval).to receive(:find_optima).with(comp1, hier)\
                                          .and_return([opt1])
      allow(eval).to receive(:find_optima).with(comp2, hier)\
                                          .and_return([opt2a, opt2b])
      @comp_list = [comp1, comp2]
      @generator = LanguageGenerator.new(eval)
    end
    it 'returns an array with both optima' do
      expect(@generator.generate_language(@comp_list, hier)).to\
        contain_exactly(opt1, opt2a, opt2b)
    end
  end
  context 'given an empty competition list' do
    before(:example) do
      @comp_list = []
      @generator = LanguageGenerator.new(eval)
    end
    it 'returns an empty language' do
      expect(@generator.generate_language(@comp_list, hier)).to be_empty
    end
  end
end

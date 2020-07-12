# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'feature'

RSpec.describe Feature do
  let(:host_class) do
    Class.new do
      include Feature
      feature_value :val1
      feature_value :val2
      define_method :initialize do
        @value = Feature::UNSET
        @type = :type_name
        @value_list = [:val1, :val2].freeze
      end
    end
  end
  before(:example) do
    @host = host_class.new
  end
  it 'has a value list' do
    expect(@host.value_list).to contain_exactly(:val1, :val2)
  end
  it 'returns its type' do
    expect(@host.type).to eq :type_name
  end
  it 'is initially unset' do
    expect(@host).to be_unset
  end
  it 'is not val1' do
    expect(@host.val1?).to be false
  end
  it 'is not val2' do
    expect(@host.val2?).to be false
  end
  it 'has valid feature value :val1' do
    expect(@host.valid_value?(:val1)).to be true
  end
  it 'rejects :val7 as an invalid value' do
    expect(@host.valid_value?(:val7)).to be false
  end
  it 'yields the valid feature values' do
    expect { |probe| @host.each_value(&probe) }.to\
      yield_successive_args(:val1, :val2)
  end

  context 'when value is set to val1' do
    before(:example) do
      @host.set_val1
    end
    it 'is val1' do
      expect(@host.val1?).to be true
    end
    it 'is not val2' do
      expect(@host.val2?).to be false
    end
  end

  context 'and another feature of same type and value' do
    let(:feature2) { double('feature 2') }
    before(:example) do
      allow(feature2).to receive(:type).and_return(:type_name)
      allow(feature2).to receive(:value).and_return(Feature::UNSET)
    end
    it 'are ==' do
      expect(@host == feature2).to be true
    end
    it 'are eql?' do
      expect(@host.eql?(feature2)).to be true
    end
  end
  context 'and another feature with a different value' do
    let(:feature2) { double('feature 2') }
    before(:example) do
      allow(feature2).to receive(:type).and_return(:type_name)
      allow(feature2).to receive(:value).and_return(:val2)
    end
    it 'are not ==' do
      expect(@host == feature2).not_to be true
    end
    it 'are not eql?' do
      expect(@host.eql?(feature2)).not_to be true
    end
  end
end

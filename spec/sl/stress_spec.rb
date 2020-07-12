# frozen_string_literal: true

# Author: Bruce Tesar

require 'sl/stress'

RSpec.describe SL::Stress do
  let(:stress) { SL::Stress::STRESS }
  let(:unstressed) { SL::Stress::UNSTRESSED }
  let(:main_stress) { SL::Stress::MAIN_STRESS }
  context 'A new stress' do
    before(:each) do
      @stress_feat = SL::Stress.new
    end
    it 'has type STRESS' do
      expect(@stress_feat.type).to eq stress
    end
    it 'should be unset' do
      expect(@stress_feat.unset?).to be true
    end
    it 'should not be unstressed' do
      expect(@stress_feat.unstressed?).to be false
    end
    it 'should not be stressed' do
      expect(@stress_feat.main_stress?).to be false
    end
    it 'should return a string value of stress=unset' do
      expect(@stress_feat.to_s).to eq('stress=unset')
    end
    it 'should accept unstressed as a valid value' do
      expect(@stress_feat.valid_value?(unstressed)).to be true
    end
    it 'should accept main_stress as a valid value' do
      expect(@stress_feat.valid_value?(main_stress)).to be true
    end
    it 'should not accept :invalid as a valid value' do
      expect(@stress_feat.valid_value?(:invalid)).to be false
    end
    it 'iterates over the feature values' do
      expect { |probe| @stress_feat.each_value(&probe) }.to\
        yield_successive_args(unstressed, main_stress)
    end

    context 'set to unstressed' do
      before(:each) do
        @stress_feat.set_unstressed
      end
      it 'should be set' do
        expect(@stress_feat.unset?).to be false
      end
      it 'should be unstressed' do
        expect(@stress_feat.unstressed?).to be true
      end
      it 'should not be stressed' do
        expect(@stress_feat.main_stress?).to be false
      end
      it 'should return a string value of stress=unstressed' do
        expect(@stress_feat.to_s).to eq('stress=unstressed')
      end
    end

    context 'set to main_stress' do
      before(:each) do
        @stress_feat.set_main_stress
      end
      it 'should be set' do
        expect(@stress_feat.unset?).to be false
      end
      it 'should not be unstressed' do
        expect(@stress_feat.unstressed?).to be false
      end
      it 'should be stressed' do
        expect(@stress_feat.main_stress?).to be true
      end
      it 'should return a string value of stress=main_stress' do
        expect(@stress_feat.to_s).to eq('stress=main_stress')
      end
    end
  end
end

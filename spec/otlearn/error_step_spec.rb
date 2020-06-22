# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/error_step'
require 'otlearn/otlearn'

RSpec.describe 'OTLearn::ErrorStep' do
  context 'given a message' do
    before(:example) do
      msg = 'Error Message'
      @err_step = OTLearn::ErrorStep.new(msg)
    end
    it 'returns its message' do
      expect(@err_step.msg).to eq 'Error Message'
    end
    it 'returns its step type' do
      expect(@err_step.step_type).to eq OTLearn::ERROR
    end
    it 'indicates that learning failed' do
      expect(@err_step.all_correct?).to be_falsey
    end
  end
end

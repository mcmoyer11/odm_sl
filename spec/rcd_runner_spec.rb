# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'rcd_runner'

RSpec.describe 'RcdRunner' do
  let(:chooser) { double('constraint chooser') }
  let(:rcd_class) { double('rcd class') }
  let(:rcd_instance) { double('rcd instance') }
  before(:example) do
    allow(rcd_class).to receive(:new).and_return(rcd_instance)
  end
  context 'called with a chooser' do
    before(:example) do
      @runner = RcdRunner.new(chooser, rcd_class: rcd_class)
    end
    context 'run with an ERC list' do
      let(:erc_list) { double('ERC list') }
      before(:example) do
        @rcd = @runner.run_rcd(erc_list)
      end
      it 'creates a new Rcd instance with the given chooser' do
        expect(rcd_class).to have_received(:new)\
          .with(erc_list, { constraint_chooser: chooser })
      end
      it 'returns the new Rcd instance' do
        expect(@rcd).to eq rcd_instance
      end
    end
  end
  context 'called without a chooser' do
    before(:example) do
      @runner = RcdRunner.new(rcd_class: rcd_class)
    end
    context 'run with an ERC list' do
      let(:erc_list) { double('ERC list') }
      before(:example) do
        @rcd = @runner.run_rcd(erc_list)
      end
      it 'returns the new Rcd instance' do
        expect(@rcd).to eq rcd_instance
      end
    end
  end
end

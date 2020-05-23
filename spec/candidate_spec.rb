# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require_relative '../lib/candidate'
require_relative '../lib/input'
require_relative '../lib/output'
require_relative '../lib/constraint'

RSpec.describe Candidate do
  let(:input) { instance_double(Input, 'input') }
  let(:output) { instance_double(Output, 'output') }

  # Test that it stores and returns the initial parameter values
  context '' do
    before(:each) do
      @constraint_list = []
      @candidate = Candidate.new(input, output, @constraint_list)
    end
    it 'returns the input' do
      expect(@candidate.input).to eq input
    end
    it 'returns the output' do
      expect(@candidate.input).to eq input
    end
    it 'returns the constraint list' do
      expect(@candidate.constraint_list).to eq @constraint_list
    end
  end

  context 'with two constraints' do
    let(:c1) { instance_double(Constraint, 'Constraint1') }
    let(:c2) { instance_double(Constraint, 'Constraint2') }
    let(:cx) { instance_double(Constraint, 'ConstraintX') }
    before(:each) do
      @constraint_list = [c1, c2]
      @candidate = Candidate.new(input, output, @constraint_list)
      @candidate.set_viols(c1, 3)
      @candidate.set_viols(c2, 1)
    end
    it 'recognizes a constraint of the candidate' do
      expect(@candidate.con?(c1)).to be true
    end
    it 'does not recognizes a constraint not of the candidate' do
      expect(@candidate.con?(cx)).to be false
    end
    it 'returns the violation count of a constraint' do
      expect(@candidate.get_viols(c1)).to eq 3
    end

    context 'and a candidate with identical violations' do
      let(:input2) { instance_double(Input, 'input2') }
      let(:output2) { instance_double(Output, 'output2') }
      before(:each) do
        @candidate2 = Candidate.new(input2, output2, @constraint_list)
        @candidate2.set_viols(c1, 3)
        @candidate2.set_viols(c2, 1)
      end
      it 'reports that the candidates have identical violations' do
        expect(@candidate.ident_viols?(@candidate2)).to be true
      end
      it 'reports that the candidates are not eql' do
        expect(@candidate.eql?(@candidate2)).to be false
      end
      it 'reports that the candidates are ==' do
        expect(@candidate == @candidate2).to be false
      end
    end

    context 'and a candidate with different violations' do
      let(:input2) { instance_double(Input, 'input2') }
      let(:output2) { instance_double(Output, 'output2') }
      before(:each) do
        @candidate2 = Candidate.new(input2, output2, @constraint_list)
        @candidate2.set_viols(c1, 3) # same viol count
        @candidate2.set_viols(c2, 0) # diff viol count
      end
      it 'reports that the candidates do not have identical violations' do
        expect(@candidate.ident_viols?(@candidate2)).to be false
      end
    end

    context 'and a duplicate is made' do
      let(:input_dup) { instance_double(Input, 'input_dup') }
      let(:output_dup) { instance_double(Output, 'output_dup') }
      before(:each) do
        allow(input).to receive(:dup).and_return(input_dup)
        allow(output).to receive(:dup).and_return(output_dup)
        @candidate_dup = @candidate.dup
      end
      it 'duplicates the input' do
        expect(input).to have_received(:dup)
      end
      it 'duplicates the output' do
        expect(output).to have_received(:dup)
      end
      it 'the dup returns the input duplicate' do
        expect(@candidate_dup.input).to eq input_dup
      end
      it 'the dup returns the output duplicate' do
        expect(@candidate_dup.output).to eq output_dup
      end
      it 'the dup has identical violations' do
        expect(@candidate.ident_viols?(@candidate_dup)).to be true
      end
    end
  end
end

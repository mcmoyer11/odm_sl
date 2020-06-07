# frozen_string_literal: true

# Author: Bruce Tesar

require 'constraint'

RSpec.describe Constraint do
  context 'A new markedness Constraint with name Constraint1 and ID Con1' do
    let(:cand1) { double('cand1') }
    let(:cand2) { double('cand2') }
    before(:example) do
      @constraint = Constraint.new('Constraint1',
                                   'Con1', Constraint::MARK) do |cand|
        viols = 2
        viols = 7 if cand == cand1
        viols
      end
    end
    it 'returns its name' do
      expect(@constraint.name).to eq('Constraint1')
    end
    it 'returns its ID' do
      expect(@constraint.id).to eq('Con1')
    end
    it 'is a markedness constraint' do
      expect(@constraint.markedness?).to be true
    end
    it 'is not a faithfulness constraint' do
      expect(@constraint.faithfulness?).to be false
    end
    it 'returns a to_s string of Con1:Constraint1' do
      expect(@constraint.to_s).to eq('Con1:Constraint1')
    end
    it 'assesses 7 violations to candidate cand1' do
      expect(@constraint.eval_candidate(cand1)).to eq(7)
    end
    it 'assesses 2 violations to candidate cand2' do
      expect(@constraint.eval_candidate(cand2)).to eq(2)
    end
  end

  context 'A new faithfulness Constraint with name Cname and ID Cid' do
    before(:example) do
      @constraint = Constraint.new('Cname', 'Cid', Constraint::FAITH) do
        return 0
      end
    end
    it 'returns its name' do
      expect(@constraint.name).to eq('Cname')
    end
    it 'returns its ID' do
      expect(@constraint.id).to eq('Cid')
    end
    it 'is not a markedness constraint' do
      expect(@constraint.markedness?).to be false
    end
    it 'is a faithfulness constraint' do
      expect(@constraint.faithfulness?).to be true
    end
    it 'returns a to_s string of Cid:Cname' do
      expect(@constraint.to_s).to eq('Cid:Cname')
    end
  end

  context '' do
    before(:example) do
      @buddy1 = Constraint.new('buddy', 'b', Constraint::MARK)
      @buddy2 = Constraint.new('buddy', 'b', Constraint::MARK)
      @notbuddy = Constraint.new('notbuddy', 'n', Constraint::MARK)
    end
    it 'is == to another constraint with the same name' do
      expect(@buddy1 == @buddy2).to be true
    end
    it 'is eql? to another constraint with the same name' do
      expect(@buddy1.eql?(@buddy2)).to be true
    end
    it 'has the same hash value as another constraint with the same name' do
      expect(@buddy1.hash).to eq(@buddy2.hash)
    end
    it 'is not == to a constraint with a different name' do
      expect(@buddy1 == @notbuddy).to be false
    end
    it 'is not eql? to a constraint with a different name' do
      expect(@buddy1.eql?(@notbuddy)).to be false
    end
    it 'does not have the same hash value as a different-named constraint' do
      expect(@buddy1.hash).not_to eq(@notbuddy.hash)
    end
  end

  context 'A new constraint set properly to MARK' do
    it 'does not raise a RuntimeError' do
      expect { Constraint.new('FCon', '1', Constraint::MARK) }.not_to\
        raise_error
    end
  end

  context 'A new Constraint with type set to OTHER' do
    it 'raises a RuntimeError' do
      expect { Constraint.new('FCon', '1', 'OTHER') }.to\
        raise_error(RuntimeError)
    end
  end

  context 'A new constraint with no evaluation block' do
    before(:example) do
      @constraint = Constraint.new('FCon', '1', Constraint::MARK)
    end
    it 'raises an exception if used to evaluate a candidate' do
      expect { @constraint.eval_candidate('cand') }.to raise_error(RuntimeError)
    end
  end
end

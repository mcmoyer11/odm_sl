# Author: Bruce Tesar

require_relative '../../lib/otlearn/grammar_test'

RSpec.describe OTLearn::GrammarTest do
  let(:winner_list){double('winner_list')}
  let(:grammar){double{'grammar'}}
  let(:lexicon){double('lexicon')}
  let(:system){double('system')}
  let(:selector){double{'loser_selector'}}
  let(:ot_mod){double{'ot_mod'}}
  let(:output_opt){double('output_opt')}
  let(:winner_opt){double('winner_opt')}
  let(:output_nopt){double('output_nopt')}
  let(:winner_nopt){double('winner_nopt')}
  let(:loser){double('loser')}
  context "" do
    before(:each) do
      allow(grammar).to receive(:system).and_return(system)
      allow(grammar).to receive(:lexicon).and_return(lexicon)
      allow(grammar).to receive(:dup).and_return(grammar)
      allow(grammar).to receive(:freeze)
      allow(grammar).to receive(:erc_list).and_return('ERCs')
      allow(system).to receive(:parse_output).with(output_opt, lexicon).and_return(winner_opt)
      allow(system).to receive(:parse_output).with(output_nopt, lexicon).and_return(winner_nopt)
      allow(winner_opt).to receive(:freeze)
      allow(winner_nopt).to receive(:freeze)
      allow(ot_mod).to receive(:mismatches_input_to_output).with(winner_opt).and_yield(winner_opt)
      allow(ot_mod).to receive(:mismatches_input_to_output).with(winner_nopt).and_yield(winner_nopt)
      allow(selector).to receive(:select_loser).with(winner_opt,"ERCs").and_return(nil)
      allow(selector).to receive(:select_loser).with(winner_nopt,"ERCs").and_return(loser)
    end
    context "given one optimal winner" do
      before(:each) do
        allow(winner_list).to receive(:map).and_return([output_opt])
        @grammar_test = OTLearn::GrammarTest.new(winner_list, grammar, "SPECS",
          loser_selector: selector, otlearn_module: ot_mod)
      end
      it "returns a list with that winner for success winners" do
        expect(@grammar_test.success_winners).to eq [winner_opt]
      end
      it "returns an empty list for failed winners" do
        expect(@grammar_test.failed_winners).to be_empty
      end
      it "reports that all winners are successful" do
        expect(@grammar_test.all_correct?).to be true
      end
    end    

    context "given one non-optimal winner" do
      before(:each) do
        allow(winner_list).to receive(:map).and_return([output_nopt])
        @grammar_test = OTLearn::GrammarTest.new(winner_list, grammar, "SPECS",
          loser_selector: selector, otlearn_module: ot_mod)
      end
      it "returns an empty list for success winners" do
        expect(@grammar_test.success_winners).to be_empty
      end
      it "returns a list with that winner for failed winners" do
        expect(@grammar_test.failed_winners).to eq [winner_nopt]
      end
      it "reports that not all winners are successful" do
        expect(@grammar_test.all_correct?).to be false
      end
    end    

    context "given one optimal and one non-optimal winner" do
      before(:each) do
        allow(winner_list).to receive(:map).and_return([output_opt, output_nopt])
        @grammar_test = OTLearn::GrammarTest.new(winner_list, grammar, "SPECS",
          loser_selector: selector, otlearn_module: ot_mod)
      end
      it "returns a list with the opt winner for success winners" do
        expect(@grammar_test.success_winners).to eq [winner_opt]
      end
      it "returns a list with the non-opt winner for failed winners" do
        expect(@grammar_test.failed_winners).to eq [winner_nopt]
      end
      it "reports that not all winners are successful" do
        expect(@grammar_test.all_correct?).to be false
      end
    end    
  end

end # RSpec.describe OTLearn::GrammarTest

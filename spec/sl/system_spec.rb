# Author: Bruce Tesar

require 'sl/system'

RSpec.describe SL::System do
  context "The SL System" do
    before(:each) do
      @system = SL::System.instance
    end

    context "returns a constraint list" do
      before(:each) do
        @con_list = @system.constraints
      end
      it "with 6 constraints" do
        expect(@con_list.size).to eq(6)
      end
      it "containing WSP" do
        expect(@con_list).to include(@system.wsp)
      end
      it "containing MainLeft" do
        expect(@con_list).to include(@system.ml)
      end
      it "containing MainRight" do
        expect(@con_list).to include(@system.mr)
      end
      it "containing NoLong" do
        expect(@con_list).to include(@system.nolong)
      end
      it "containing Ident[stress]" do
        expect(@con_list).to include(@system.idstress)
      end
      it "containing Ident[length]" do
        expect(@con_list).to include(@system.idlength)
      end
    end

    context "given a candidate" do
      before(:each) do
        @cand = double("candidate")
        @input = Array.new()
        @output = Array.new()
        @io_corr = Array.new()
        allow(@cand).to receive(:input).and_return(@input)
        allow(@cand).to receive(:output).and_return(@output)
        allow(@cand).to receive(:io_corr).and_return(@io_corr)
      end
      
      context "/S:/[S:]" do
        before(:each) do
          # input syllable
          @syli1 = double("Syli1")
          @input << @syli1
          allow(@syli1).to receive(:long?).and_return(true)
          allow(@syli1).to receive(:unstressed?).and_return(false)
          allow(@syli1).to receive(:main_stress?).and_return(true)
          allow(@syli1).to receive(:stress_unset?).and_return(false)
          allow(@syli1).to receive(:length_unset?).and_return(false)
          # output syllable
          @sylo1 = double("Sylo1")
          @output << @sylo1
          allow(@sylo1).to receive(:long?).and_return(true)
          allow(@sylo1).to receive(:unstressed?).and_return(false)
          allow(@sylo1).to receive(:main_stress?).and_return(true)
          # IO correspondence
          @io_corr << [@syli1, @sylo1]
        end
        it "assigns 1 violation of NoLong" do
          expect(@system.nolong.eval_candidate(@cand)).to eq(1)
        end
        it "assigns 0 violations of WSP" do
          expect(@system.wsp.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 0 violations of ML" do
          expect(@system.ml.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 0 violations of MR" do
          expect(@system.mr.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 0 violations of IDStress" do
          expect(@system.idstress.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 0 violations of IDLength" do
          expect(@system.idlength.eval_candidate(@cand)).to eq(0)
        end
      end
      
      context "/s:/[S]" do
        before(:each) do
          # input syllable
          @syli1 = double("Syli1")
          @input << @syli1
          allow(@syli1).to receive(:long?).and_return(true)
          allow(@syli1).to receive(:unstressed?).and_return(true)
          allow(@syli1).to receive(:main_stress?).and_return(false)
          allow(@syli1).to receive(:stress_unset?).and_return(false)
          allow(@syli1).to receive(:length_unset?).and_return(false)
          # output syllable
          @sylo1 = double("Sylo1")
          @output << @sylo1
          allow(@sylo1).to receive(:long?).and_return(false)
          allow(@sylo1).to receive(:unstressed?).and_return(false)
          allow(@sylo1).to receive(:main_stress?).and_return(true)
          # IO correspondence
          @io_corr << [@syli1, @sylo1]
        end
        it "assigns 0 violations of NoLong" do
          expect(@system.nolong.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 0 violations of WSP" do
          expect(@system.wsp.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 0 violations of ML" do
          expect(@system.ml.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 0 violations of MR" do
          expect(@system.mr.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 1 violation of IDStress" do
          expect(@system.idstress.eval_candidate(@cand)).to eq(1)
        end
        it "assigns 1 violation of IDLength" do
          expect(@system.idlength.eval_candidate(@cand)).to eq(1)
        end        
      end

      context "/ss:/[Ss:]" do
        before(:each) do
          # input syllable 1
          @syli1 = double("Syli1")
          @input << @syli1
          allow(@syli1).to receive(:long?).and_return(false)
          allow(@syli1).to receive(:unstressed?).and_return(true)
          allow(@syli1).to receive(:main_stress?).and_return(false)
          allow(@syli1).to receive(:stress_unset?).and_return(false)
          allow(@syli1).to receive(:length_unset?).and_return(false)
          # input syllable 2
          @syli2 = double("Syli2")
          @input << @syli2
          allow(@syli2).to receive(:long?).and_return(true)
          allow(@syli2).to receive(:unstressed?).and_return(true)
          allow(@syli2).to receive(:main_stress?).and_return(false)
          allow(@syli2).to receive(:stress_unset?).and_return(false)
          allow(@syli2).to receive(:length_unset?).and_return(false)
          # output syllable 1
          @sylo1 = double("Sylo1")
          @output << @sylo1
          allow(@sylo1).to receive(:long?).and_return(false)
          allow(@sylo1).to receive(:unstressed?).and_return(false)
          allow(@sylo1).to receive(:main_stress?).and_return(true)
          # output syllable 2
          @sylo2 = double("Sylo2")
          @output << @sylo2
          allow(@sylo2).to receive(:long?).and_return(true)
          allow(@sylo2).to receive(:unstressed?).and_return(true)
          allow(@sylo2).to receive(:main_stress?).and_return(false)
          # IO correspondence
          @io_corr << [@syli1, @sylo1] << [@syli2, @sylo2]
        end
        it "assigns 1 violation of NoLong" do
          expect(@system.nolong.eval_candidate(@cand)).to eq(1)
        end
        it "assigns 1 violation of WSP" do
          expect(@system.wsp.eval_candidate(@cand)).to eq(1)
        end
        it "assigns 0 violations of ML" do
          expect(@system.ml.eval_candidate(@cand)).to eq(0)
        end
        it "assigns 1 violation of MR" do
          expect(@system.mr.eval_candidate(@cand)).to eq(1)
        end
        it "assigns 1 violation of IDStress" do
          expect(@system.idstress.eval_candidate(@cand)).to eq(1)
        end
        it "assigns 0 violations of IDLength" do
          expect(@system.idlength.eval_candidate(@cand)).to eq(0)
        end        
      end
      
    end
    
    context "with a lexicon including r1 /s./ and s4 /S:/" do
      before(:each) do
        @gram = double()
        allow(@gram).to receive(:get_uf).with("r1").and_return(["s."])
        allow(@gram).to receive(:get_uf).with("s4").and_return(["S:"])
      end
      
      context "with morphword ['r1']" do
        before(:each) do
          @mw = double()
          allow(@mw).to receive(:each).and_yield("r1")
        end
        it "#input_from_morphword returns input with morphword r1" do
          input = @system.input_from_morphword(@mw, @gram)
          expect(input.morphword).to eq(@mw)
        end
        it "#input_from_morphword returns input [s.]" do
          input = @system.input_from_morphword(@mw, @gram)
          expect(input).to eq(["s."])
        end
        it "#input_from_morphword returns input with 1 ui pair [s.,s.]" do
          input = @system.input_from_morphword(@mw, @gram)
          ui_corr = input.ui_corr
          expect(ui_corr.size).to eq(1)
          expect(ui_corr[0]).to eq(["s.","s."])
        end
      end

      context "with morphword ['r1', 's4']" do
        before(:each) do
          @mw = double()
          allow(@mw).to receive(:each).and_yield("r1").and_yield("s4")
        end
        it "#input_from_morphword returns input with morphword r1s4" do
          input = @system.input_from_morphword(@mw, @gram)
          expect(input.morphword).to eq(@mw)
        end
        it "#input_from_morphword returns input [s.,S:]" do
          input = @system.input_from_morphword(@mw, @gram)
          expect(input).to eq(["s.","S:"])
        end
        it "#input_from_morphword returns input with 2 ui pairs, [s.,s.] and [S:,S:]" do
          input = @system.input_from_morphword(@mw, @gram)
          ui_corr = input.ui_corr
          expect(ui_corr.size).to eq(2)
          expect(ui_corr[0]).to eq(["s.","s."])
          expect(ui_corr[1]).to eq(["S:","S:"])
        end
      end
                  
      it "raises an exception when the morpheme has no lexical entry" do
        mw = double()
        bad_m = double(:label => "x1")
        allow(@gram).to receive(:get_uf).with(bad_m).and_return(nil)
        allow(mw).to receive(:each).and_yield(bad_m)
        expect {@system.input_from_morphword(mw, @gram)}.to raise_error(RuntimeError)
      end

    end
  end
end # describe SL::System

# Author: Bruce Tesar

require 'sl/system'
require 'lexicon'
require 'lexical_entry'
require 'morph_word'
require 'sl/syllable'

RSpec.describe SL::System do
  before(:each) do
    @system = SL::System.instance
  end

  #*********************************
  # Specs for the system constraints
  #*********************************
  context "System returns a constraint list" do
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
  context "System, given candidate" do
    before(:each) do
      @cand = double("candidate")
      @input = Array.new()
      @output = Array.new()
      @io_corr = IOCorrespondence.new
      allow(@cand).to receive(:input).and_return(@input)
      allow(@cand).to receive(:output).and_return(@output)
      allow(@cand).to receive(:io_corr).and_return(@io_corr)
    end
    context "/S:/[S:]" do
      before(:each) do
        # input syllable
        @syli1 = instance_double(SL::Syllable, "Syli1")
        @input << @syli1
        allow(@syli1).to receive(:long?).and_return(true)
        allow(@syli1).to receive(:unstressed?).and_return(false)
        allow(@syli1).to receive(:main_stress?).and_return(true)
        allow(@syli1).to receive(:stress_unset?).and_return(false)
        allow(@syli1).to receive(:length_unset?).and_return(false)
        # output syllable
        @sylo1 = instance_double(SL::Syllable, "Sylo1")
        @output << @sylo1
        allow(@sylo1).to receive(:long?).and_return(true)
        allow(@sylo1).to receive(:unstressed?).and_return(false)
        allow(@sylo1).to receive(:main_stress?).and_return(true)
        # IO correspondence
        @io_corr.add_corr(@syli1, @sylo1)
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
        @syli1 = instance_double(SL::Syllable, "Syli1")
        @input << @syli1
        allow(@syli1).to receive(:long?).and_return(true)
        allow(@syli1).to receive(:unstressed?).and_return(true)
        allow(@syli1).to receive(:main_stress?).and_return(false)
        allow(@syli1).to receive(:stress_unset?).and_return(false)
        allow(@syli1).to receive(:length_unset?).and_return(false)
        # output syllable
        @sylo1 = instance_double(SL::Syllable, "Sylo1")
        @output << @sylo1
        allow(@sylo1).to receive(:long?).and_return(false)
        allow(@sylo1).to receive(:unstressed?).and_return(false)
        allow(@sylo1).to receive(:main_stress?).and_return(true)
        # IO correspondence
        @io_corr.add_corr(@syli1, @sylo1)
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
        @syli1 = instance_double(SL::Syllable, "Syli1")
        @input << @syli1
        allow(@syli1).to receive(:long?).and_return(false)
        allow(@syli1).to receive(:unstressed?).and_return(true)
        allow(@syli1).to receive(:main_stress?).and_return(false)
        allow(@syli1).to receive(:stress_unset?).and_return(false)
        allow(@syli1).to receive(:length_unset?).and_return(false)
        # input syllable 2
        @syli2 = instance_double(SL::Syllable, "Syli2")
        @input << @syli2
        allow(@syli2).to receive(:long?).and_return(true)
        allow(@syli2).to receive(:unstressed?).and_return(true)
        allow(@syli2).to receive(:main_stress?).and_return(false)
        allow(@syli2).to receive(:stress_unset?).and_return(false)
        allow(@syli2).to receive(:length_unset?).and_return(false)
        # output syllable 1
        @sylo1 = instance_double(SL::Syllable, "Sylo1")
        @output << @sylo1
        allow(@sylo1).to receive(:long?).and_return(false)
        allow(@sylo1).to receive(:unstressed?).and_return(false)
        allow(@sylo1).to receive(:main_stress?).and_return(true)
        # output syllable 2
        @sylo2 = instance_double(SL::Syllable, "Sylo2")
        @output << @sylo2
        allow(@sylo2).to receive(:long?).and_return(true)
        allow(@sylo2).to receive(:unstressed?).and_return(true)
        allow(@sylo2).to receive(:main_stress?).and_return(false)
        # IO correspondence
        @io_corr.add_corr(@syli1, @sylo1).add_corr(@syli2, @sylo2)
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
    context "/s.s:/[s.S:]" do
      before(:each) do
        # input syllable 1
        @syli1 = instance_double(SL::Syllable, "Syli1")
        @input << @syli1
        allow(@syli1).to receive(:long?).and_return(false)
        allow(@syli1).to receive(:unstressed?).and_return(true)
        allow(@syli1).to receive(:main_stress?).and_return(false)
        allow(@syli1).to receive(:stress_unset?).and_return(false)
        allow(@syli1).to receive(:length_unset?).and_return(false)
        # input syllable 2
        @syli2 = instance_double(SL::Syllable, "Syli2")
        @input << @syli2
        allow(@syli2).to receive(:long?).and_return(true)
        allow(@syli2).to receive(:unstressed?).and_return(true)
        allow(@syli2).to receive(:main_stress?).and_return(false)
        allow(@syli2).to receive(:stress_unset?).and_return(false)
        allow(@syli2).to receive(:length_unset?).and_return(false)
        # output syllable 1
        @sylo1 = instance_double(SL::Syllable, "Sylo1")
        @output << @sylo1
        allow(@sylo1).to receive(:long?).and_return(false)
        allow(@sylo1).to receive(:unstressed?).and_return(true)
        allow(@sylo1).to receive(:main_stress?).and_return(false)
        # output syllable 2
        @sylo2 = instance_double(SL::Syllable, "Sylo2")
        @output << @sylo2
        allow(@sylo2).to receive(:long?).and_return(true)
        allow(@sylo2).to receive(:unstressed?).and_return(false)
        allow(@sylo2).to receive(:main_stress?).and_return(true)
        # IO correspondence
        @io_corr.add_corr(@syli1, @sylo1).add_corr(@syli2, @sylo2)
      end
      it "assigns 1 violation of NoLong" do
        expect(@system.nolong.eval_candidate(@cand)).to eq(1)
      end
      it "assigns 0 violation of WSP" do
        expect(@system.wsp.eval_candidate(@cand)).to eq(0)
      end
      it "assigns 1 violations of ML" do
        expect(@system.ml.eval_candidate(@cand)).to eq(1)
      end
      it "assigns 0 violation of MR" do
        expect(@system.mr.eval_candidate(@cand)).to eq(0)
      end
      it "assigns 1 violation of IDStress" do
        expect(@system.idstress.eval_candidate(@cand)).to eq(1)
      end
      it "assigns 0 violations of IDLength" do
        expect(@system.idlength.eval_candidate(@cand)).to eq(0)
      end
    end
  end

  #****************************************
  # Specs for #input_from_morphword()
  #****************************************
  context "System with a lexicon including r1 /s./ and s4 /S:/" do
    before(:each) do
      @lex_entry_r1 = instance_double(Lexical_Entry, "lex_entry_r1")
      allow(@lex_entry_r1).to receive(:nil?).and_return(false)
      allow(@lex_entry_r1).to receive(:morpheme).and_return("r1")
      allow(@lex_entry_r1).to receive(:uf).and_return(["s."])
      @lex_entry_s4 = instance_double(Lexical_Entry, "lex_entry_s4")
      allow(@lex_entry_s4).to receive(:nil?).and_return(false)
      allow(@lex_entry_s4).to receive(:morpheme).and_return("s4")
      allow(@lex_entry_s4).to receive(:uf).and_return(["S:"])
      @lexicon = [@lex_entry_r1, @lex_entry_s4]
    end
    context "with morphword ['r1']" do
      before(:each) do
        @mw = instance_double(MorphWord, "morphword ['r1']")
        allow(@mw).to receive(:each).and_yield("r1")
      end
      it "#input_from_morphword returns input with morphword r1" do
        input = @system.input_from_morphword(@mw, @lexicon)
        expect(input.morphword).to eq(@mw)
      end
      it "#input_from_morphword returns input [s.]" do
        input = @system.input_from_morphword(@mw, @lexicon)
        expect(input).to eq(["s."])
      end
      it "#input_from_morphword returns input with 1 ui pair [s.,s.]" do
        input = @system.input_from_morphword(@mw, @lexicon)
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
        input = @system.input_from_morphword(@mw, @lexicon)
        expect(input.morphword).to eq(@mw)
      end
      it "#input_from_morphword returns input [s.,S:]" do
        input = @system.input_from_morphword(@mw, @lexicon)
        expect(input).to eq(["s.","S:"])
      end
      it "#input_from_morphword returns input with 2 ui pairs, [s.,s.] and [S:,S:]" do
        input = @system.input_from_morphword(@mw, @lexicon)
        ui_corr = input.ui_corr
        expect(ui_corr.size).to eq(2)
        expect(ui_corr[0]).to eq(["s.","s."])
        expect(ui_corr[1]).to eq(["S:","S:"])
      end
    end
    it "raises an exception when the morpheme has no lexical entry" do
      mw = double()
      bad_m = double(:label => "x1")
      allow(mw).to receive(:each).and_yield(bad_m)
      expect {@system.input_from_morphword(mw, @lexicon)}.to raise_error(RuntimeError)
    end
  end
  
  #*****************
  # Specs for #gen()
  #*****************
  
  # A real challenge with using test doubles here is the wide use of
  # #dup methods internally, on classes like Input and Syllable.
  # It requires that mock object creation methods be created and threaded
  # into the initial mock objects, and new stubs must be added to each of the
  # newly created mock objects, *and* duplication of state of duped mock
  # objects must be replicated.
  # Here, the actual classes Input and Syllable are used.

  # *** 1-Syllable Examples ***
  
  RSpec.shared_examples "1-syllable Word" do
    it "has input == to the original input" do
      expect(@word.input).to eq(@input)
    end
    it "has morphword r1" do
      expect(@word.morphword).to eq("r1")
    end
    it "has input syl1 associated with r1" do
      expect(@word.input[0].morpheme).to eq("r1")
    end
    it "input syl1 has IO correspondent output syl1" do
      expect(@word.io_corr.out_corr(@word.input[0])).to eq(@word.output[0])
    end
    it "output syl1 has IO correspondent input syl1" do
      expect(@word.io_corr.in_corr(@word.output[0])).to eq(@word.input[0])
    end
  end

  context "Given input /s:/" do
    before(:each) do
      @syl = SL::Syllable.new.set_unstressed.set_long.set_morpheme("r1")
      @input = Input.new
      @input.morphword = "r1"
      @input << @syl
      @competition = @system.gen(@input)
    end
    it "gen generates a competition with 6 constraints" do
      expect(@competition.constraint_list.size).to eq(6)
    end
    it "generates 2 candidates" do
      expect(@competition.size).to eq(2)
    end
    ["S.","S:"].each do |out_str|
      context "candidate with output #{out_str}" do
        before(:each) {@word = @competition.find{|w| w.output.to_s == out_str}}
        it "generates candidate with output #{out_str}" do
          expect(@word).not_to be nil
        end
        include_examples "1-syllable Word"
      end
    end
  end

  # *** 2-Syllable Examples ***
  
  RSpec.shared_examples "2-syllable Word" do
    it "has input == to the original input" do
      expect(@word.input).to eq(@input)
    end
    it "has morphword r1s1" do
      expect(@word.morphword).to eq("r1s1")
    end
    it "has input syl1 associated with r1" do
      expect(@word.input[0].morpheme).to eq("r1")
    end
    it "has input syl2 associated with s1" do
      expect(@word.input[1].morpheme).to eq("s1")
    end
    it "input syl1 has IO correspondent output syl1" do
      expect(@word.io_corr.out_corr(@word.input[0])).to eq(@word.output[0])
    end
    it "input syl2 has IO correspondent output syl2" do
      expect(@word.io_corr.out_corr(@word.input[1])).to eq(@word.output[1])
    end
    it "output syl1 has IO correspondent input syl1" do
      expect(@word.io_corr.in_corr(@word.output[0])).to eq(@word.input[0])
    end
    it "output syl2 has IO correspondent input syl2" do
      expect(@word.io_corr.in_corr(@word.output[1])).to eq(@word.input[1])
    end
  end

  RSpec.shared_examples "2-syllable outputs" do
    it "gen generates a competition with 6 constraints" do
      expect(@competition.constraint_list.size).to eq(6)
    end
    it "generates 8 candidates" do
      expect(@competition.size).to eq(8)
    end
    ["S.s.","S.s:","S:s.","S:s:","s.S.","s.S:","s:S.","s:S:"].each do |out_str|
      context "candidate with output #{out_str}" do
        before(:each) {@word = @competition.find{|w| w.output.to_s == out_str}}
        it "generates candidate with output #{out_str}" do
          expect(@word).not_to be nil
        end
        include_examples "2-syllable Word"
      end
    end
  end
  
  context "Given input /s:S./" do
    before(:each) do
      @syl1 = SL::Syllable.new.set_unstressed.set_long.set_morpheme("r1")
      @syl2 = SL::Syllable.new.set_main_stress.set_short.set_morpheme("s1")
      @input = Input.new
      @input.morphword = "r1s1"
      @input << @syl1 << @syl2
      @competition = @system.gen(@input)
    end
    include_examples "2-syllable outputs"
  end
  
  #**************************
  # Specs for #parse_output()
  #**************************

  RSpec.shared_examples "parsed output" do
    it "with output == to the starting output" do
      expect(@word.output).to eq(@output)
    end
    it "with input matching the lexical entries" do
      expect(@word.input).to eq(@input)
    end
    it "with morphword matching the output's morphword" do
      expect(@word.morphword).to eq(@morphword)
    end
    it "input syl1 has IO correspondent output syl1" do
      expect(@word.io_corr.out_corr(@word.input[0])).to eq(@word.output[0])
    end
    it "input syl2 has IO correspondent output syl2" do
      expect(@word.io_corr.out_corr(@word.input[1])).to eq(@word.output[1])
    end
    it "output syl1 has IO correspondent input syl1" do
      expect(@word.io_corr.in_corr(@word.output[0])).to eq(@word.input[0])
    end
    it "output syl2 has IO correspondent input syl2" do
      expect(@word.io_corr.in_corr(@word.output[1])).to eq(@word.input[1])
    end    
  end
  
  context "with lexicon including r1 /s./ and s1 /S:/" do
    before(:each) do
      @in_sylr1 = SL::Syllable.new.set_unstressed.set_short.set_morpheme("r1")
      @lex_entry_r1 = double("lex_entry_r1")
      allow(@lex_entry_r1).to receive(:nil?).and_return(false)
      allow(@lex_entry_r1).to receive(:morpheme).and_return("r1")
      allow(@lex_entry_r1).to receive(:uf).and_return([@in_sylr1])
      @in_syls1 = SL::Syllable.new.set_main_stress.set_long.set_morpheme("s1")
      @lex_entry_s1 = double("lex_entry_s1")
      allow(@lex_entry_s1).to receive(:nil?).and_return(false)
      allow(@lex_entry_s1).to receive(:morpheme).and_return("s1")
      allow(@lex_entry_s1).to receive(:uf).and_return([@in_syls1])
      @lex = [@lex_entry_r1, @lex_entry_s1]
      @input = Input.new << @in_sylr1.dup << @in_syls1.dup # distinct objects from the ones in the lexicon
    end
    context "and output s.S. it parses to a candidate" do
      before(:each) do
        @out_syl1 = SL::Syllable.new.set_unstressed.set_short.set_morpheme("r1")
        @out_syl2 = SL::Syllable.new.set_main_stress.set_short.set_morpheme("s1")
        @morphword = instance_double("Morphword")
        allow(@morphword).to receive(:each).and_yield("r1").and_yield("s1")
        @output = Output.new << @out_syl1 << @out_syl2
        @output.morphword = @morphword
        @word = @system.parse_output(@output,@lex)
      end
      include_examples "parsed output"
    end
  end

  context "with a lexicon containing only r1 /s./" do
    before(:each) do
      @in_sylr1 = SL::Syllable.new.set_unstressed.set_short.set_morpheme("r1")
      @lex_entry_r1 = instance_double(Lexical_Entry, "lex_entry_r1")
      allow(@lex_entry_r1).to receive(:nil?).and_return(false)
      allow(@lex_entry_r1).to receive(:morpheme).and_return("r1")
      allow(@lex_entry_r1).to receive(:uf).and_return([@in_sylr1])
      
      @lex = instance_double(Lexicon, "lexicon")
      allow(@lex).to receive(:any?).and_return(true,false) # only r1 is in the lexicon
      allow(@lex).to receive(:find).and_return(@lex_entry_r1,nil) # only r1 is in the lexicon

      @in_syls1 = SL::Syllable.new.set_morpheme("s1")
      @lex_entry_s1 = instance_double(Lexical_Entry, "lex_entry_s1")
      allow(@lex_entry_s1).to receive(:nil?).and_return(false)
      allow(@lex_entry_s1).to receive(:morpheme).and_return("s1")
      allow(@lex_entry_s1).to receive(:uf).and_return([@in_syls1])
      
      allow(@lex).to receive(:find).and_return(@lex_entry_r1,@lex_entry_s1) # should only be called *after* the lexical entry would have been added
      # the input *after* the new lexical entry for s1 is created
      @input = Input.new << @in_sylr1.dup << @in_syls1.dup # distinct objects from the ones in the lexicon
    end
    context "and output s.S." do
      before(:each) do
        @out_syl1 = SL::Syllable.new.set_unstressed.set_short.set_morpheme("r1")
        @out_syl2 = SL::Syllable.new.set_main_stress.set_short.set_morpheme("s1")
        @morphword = instance_double("Morphword")
        allow(@morphword).to receive(:each).and_yield("r1").and_yield("s1")
        @output = Output.new << @out_syl1 << @out_syl2
        @output.morphword = @morphword
      end
      it "creates a new lexical entry for s1" do
        # There is no simple way to test the argument given to :<<, i.e.,
        # the lexical entry. This might be a job for a test spy, or
        # a partial test dummy, but I won't pursue it at this time.
        expect(@lex).to receive(:<<).once
        @word = @system.parse_output(@output,@lex)
      end
      context "when parsed," do
        before(:each) do
          allow(@lex).to receive(:<<).once
          @word = @system.parse_output(@output,@lex)
        end
        include_examples "parsed output"
        it "the word's 2nd input syllable is unset for stress" do
          expect(@word.input[1].stress_unset?).to be true
        end
        it "the word's 2nd input syllable is unset for length" do
          expect(@word.input[1].length_unset?).to be true
        end
      end
    end
  end
  
end # describe SL::System

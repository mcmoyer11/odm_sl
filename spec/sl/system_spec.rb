# Author: Bruce Tesar

require 'sl/system'
require 'input_factory'

describe SL::System do
  context "The SL System" do
    before(:each) do
      @system = SL::System.instance
      @system.set_input_factory(Input_factory.new)
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
    
    #TODO: modify class System so that the Input class dependency is passed in.
    context "with a lexicon including r1 /s./ and s4 /S:/" do
      before(:each) do
        @gram = double()
        allow(@gram).to receive(:get_uf).with(["r1"]).and_return(["s."])
        allow(@gram).to receive(:get_uf).with(["s4"]).and_return(["S:"])
      end
      it "#input_from_morphword returns input /s./ for morphword r1" do
        mw = double()
        allow(mw).to receive(:each).and_yield(["r1"])
        expect(@system.input_from_morphword(mw, @gram).join).to eq("s.")
      end
      it "#input_from_morphword returns input /s.S:/ for morphword r1s4" do
        mw = double()
        allow(mw).to receive(:each).and_yield(["r1"]).and_yield(["s4"])
        expect(@system.input_from_morphword(mw, @gram).join).to eq("s.S:")
      end
    end
  end
end # describe System

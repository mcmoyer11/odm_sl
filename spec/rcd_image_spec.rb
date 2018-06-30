# Author: Bruce Tesar

require 'rcd_image'
require 'sheet'
require_relative '../test/helpers/quick_erc'

RSpec.describe RcdImage, :wip do  
  let(:rcd_result){double('rcd_result')}
  let(:ct_image_class){double('ct_image_class')}
  let(:ct_image){Sheet.new}
  before(:each) do
    stub_const 'ML', Test::ML
    stub_const 'ME', Test::ME
    stub_const 'MW', Test::MW
    allow(ct_image_class).to receive(:new).and_return(ct_image)
    ct_image[1,1] = "CT IMAGE"
  end

  context "given RCD result with one ERC [W]" do
    let(:erc1){Test.quick_erc([MW])}
    let(:unsorted_constraints){erc1.constraint_list}
    let(:con1){unsorted_constraints[0]}
    let(:sorted_ercs){[erc1]}
    let(:sorted_constraints){[con1]}
    before(:each) do
      allow(rcd_result).to receive(:ranked).and_return([[con1]])
      allow(rcd_result).to receive(:unranked).and_return([])
      allow(rcd_result).to receive(:ex_ercs).and_return([[erc1]])
      allow(rcd_result).to receive(:unex_ercs).and_return([])
      @rcd_image =
        RcdImage.new(rcd_result, comp_tableau_image_class: ct_image_class)
    end
    it "contains the given RCD result" do
      expect(@rcd_image.rcd_result).to eq rcd_result
    end
    it "has the comp tableau image starting at [1,1]" do
      expect(@rcd_image[1,1]).to eq 'CT IMAGE'
    end
    it "constructs a CT image with one constraint and one erc" do
      expect(ct_image_class).to have_received(:new).
        with(sorted_ercs, sorted_constraints)
    end
  end

  context "with ercs initially in reverse order" do
    let(:erc1){Test.quick_erc([ML,ME,MW])}
    let(:erc2){Test.quick_erc([MW,MW,ML])}
    let(:unsorted_constraints){erc1.constraint_list}
    let(:con1){unsorted_constraints[0]}
    let(:con2){unsorted_constraints[1]}
    let(:con3){unsorted_constraints[2]}
    let(:sorted_ercs){[erc2,erc1]}
    let(:sorted_constraints){[con2,con3,con1]}
    before(:each) do
      allow(rcd_result).to receive(:ranked).and_return([[con2],[con3],[con1]])
      allow(rcd_result).to receive(:unranked).and_return([])
      allow(rcd_result).to receive(:ex_ercs).and_return([[erc1,erc2]])
      allow(rcd_result).to receive(:unex_ercs).and_return([])
      @rcd_image =
        RcdImage.new(rcd_result, comp_tableau_image_class: ct_image_class)
    end
    it "contains the given RCD result" do
      expect(@rcd_image.rcd_result).to eq rcd_result
    end
    it "has the comp tableau image starting at [1,1]" do
      expect(@rcd_image[1,1]).to eq 'CT IMAGE'
    end
    it "constructs a CT image with properly sorted ercs and constraints" do
      expect(ct_image_class).to have_received(:new).
        with(sorted_ercs, sorted_constraints)
    end
  end

end # RSpec.describe RcdImage

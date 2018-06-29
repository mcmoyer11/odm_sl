# Author: Bruce Tesar

require 'rcd_image'
require 'sheet'

RSpec.describe RcdImage, :wip do
  context "given RCD result with one ERC [W]" do
    let(:rcd_result){double('rcd_result')}
    let(:ct_image_class){double('ct_image_class')}
    let(:ct_image){Sheet.new}
    let(:con1){double('con1')}
    let(:erc1){double('erc1')}
    let(:rcd_hierarchy){[[con1]]}
    let(:ercs){[[erc1]]}
    before(:each) do
      allow(rcd_result).to receive(:hierarchy).and_return(rcd_hierarchy)
      allow(rcd_result).to receive(:unranked).and_return([])
      allow(rcd_result).to receive(:ex_ercs).and_return(ercs)
      allow(rcd_result).to receive(:unex_ercs).and_return([])
      allow(erc1).to receive(:w?).with(con1).and_return(true)
      allow(ct_image_class).to receive(:new).and_return(ct_image)
      @rcd_image = RcdImage.new(rcd_result, comp_tableau_image_class: ct_image_class)
    end
    it "contains the given RCD result" do
      expect(@rcd_image.rcd_result).to eq rcd_result
    end
  end
end


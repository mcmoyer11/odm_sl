# Author: Bruce Tesar

require 'rcd_image'

RSpec.describe RCD_image, :wip do
  context "given RCD result" do
    let(:rcd_result){double('rcd_result')}
    before(:each) do
      pending "RCD_image refactoring from inheritance to dependency injection."
      @rcd_image = RCD_image.new(rcd_result)
    end
    it "contains the given RCD result" do
      expect(@rcd_image.rcd_result).to eq rcd_result
    end
  end
end


# Author: Bruce Tesar
#
# This acceptance spec runs learning on all 24 SL languages,
# and checks the generated learning outputs against the test fixtures.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

project_dir = "C:/Users/Tesar/NetBeansProjects/odm_sl"
sl_fixture_dir = File.join(project_dir,'test','fixtures','sl_learning')
generated_dir = File.join(project_dir,'temp','sl_learning')
RSpec.describe "Running odm on all 24 SL languages", :acceptance do
  before(:each) do
    load "bin/r1s1_typology.rb"
    @success = system "diff #{sl_fixture_dir} #{generated_dir}"
  end

  it "produces output matching the test fixtures" do
    expect(@success).to be true
  end
end


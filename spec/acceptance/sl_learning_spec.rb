# Author: Bruce Tesar
#
# This acceptance spec runs learning on all 24 SL languages,
# and checks the generated learning outputs against the test fixtures.

require_relative '../../lib/odl/resolver'

RSpec.describe 'Running ODL on SL', :acceptance do
  before(:context) do
    project_dir = ODL::PROJECT_DIR
    @sl_fixture_dir = File.join(project_dir,'test','fixtures','sl_learning')
    @generated_dir = File.join(project_dir,'temp','sl_learning')
    # The executable dir must be a relative path, otherwise a bunch of
    # warnings are generated about redefining constants when the load
    # command is executed. Maybe the paths fed to the require statements
    # look different with an absolute path, and require fails to recognize
    # that a file has already been required?
    executable_dir = File.join('bin','sl')
    load "#{executable_dir}/learn_typology_1r1s.rb"
  end

  (1..24).each do |num|
    context "on language L#{num}" do
      before(:example) do
        @success = system "diff #{@sl_fixture_dir}/LgL#{num}.csv #{@generated_dir}/LgL#{num}.csv"
      end

      it 'produces output that matches its test fixture' do
        expect(@success).to be true
      end
    end
  end
end

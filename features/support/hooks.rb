# Hooks for the Cucumber scenarios.

require 'fileutils'

Before do
  @project_dir = File.expand_path('../../..',__FILE__)
  @test_dir = File.join(@project_dir,'test')
  @generated_dir = File.join(@test_dir,'generated')
  @fixture_dir = File.join(@test_dir,'fixtures')
end

After do
end

# Hooks for the Cucumber scenarios.

Before do
  @project_dir = File.expand_path('../../..',__FILE__)
  @test_dir = File.join(@project_dir,'test')
  @fixture_dir = File.join(@test_dir,'fixtures')
end

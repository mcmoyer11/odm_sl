# Author: Bruce Tesar

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'launchy'

# Top-level project directory.
PROJECT_DIR = File.dirname(__FILE__)

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb', 'bin/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "odm_sl Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

desc "delete all files in the temp dir"
task :clear_temp do
  Dir.glob("#{PROJECT_DIR}/temp/**/*").each do |f|
    File.delete f
  end
end

#************
# RSpec Tasks
#************

RSpec::Core::RakeTask.new do |t|
end

RSpec::Core::RakeTask.new(:spec_html) do |t|
  t.rspec_opts = "-f html -o temp/rspec_report.html"
end

desc "display RSpec in browser"
task :spec_in_browser => [:clear_temp, :spec_html] do
  # Display the rspec report in the system's default browser.
  Launchy.open("#{PROJECT_DIR}/temp/rspec_report.html")
end

#***************
# Cucumber Tasks
#***************

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "--format pretty"
end

Cucumber::Rake::Task.new(:cucumber_html, "Generate cucumber HTML") do |t|
  t.cucumber_opts = "-f html -o temp/cucumber_report.html"
end

desc "display cucumber in browser"
task :cucumber_in_browser => [:clear_temp, :cucumber_html] do
  # Display the cucumber report in the system's default browser.
  Launchy.open("#{PROJECT_DIR}/temp/cucumber_report.html")
end

#**********
# Packaging
#**********

spec = Gem::Specification.new do |s|
  s.name = 'odm_sl'
  s.version = '0.0.1'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Your summary here'
  s.description = s.summary
  s.author = ''
  s.email = ''
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

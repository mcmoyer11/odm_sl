# Author: Bruce Tesar

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'launchy'

# This monkeypatch overcomes a weird (jruby & netbeans & rake) bug:
# the dreaded jruby.bat.exe bug.
# If the constant FileUtils::RUBY contains "jruby.bat.exe", this patch
# effectively changes that to "jruby", so that jruby will be properly invoked.
# It allows rake to properly call ruby executables like rspec.
if (FileUtils::RUBY =~ /jruby\.bat\.exe/) then
  # Temporarily turn off warnings, to suppress a warning about
  # reinitializing the constant RUBY.
  verbose_val = $VERBOSE
  $VERBOSE = nil  # the value false doesn't work
  # It generates a warning because it re-initializes a constant that
  # was set (problematically) in stdlib\rake\file_utils.rb lines 9-12.
  FileUtils::RUBY = File.join(RbConfig::CONFIG['bindir'], "jruby")
  # Reset the value of $VERBOSE to what is was.
  # Normally, this should turn warnings back on.
  $VERBOSE = verbose_val
end

# Top-level project directory.
PROJECT_DIR = File.dirname(__FILE__)

desc "delete all files/directories in the temp dir"
task :clear_temp do
  Dir.glob("#{PROJECT_DIR}/temp/*").each do |f|
    rm_rf(f, :verbose => false)
  end
end

#***********
# RDoc Tasks
#***********

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb', 'bin/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "odm_sl Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

desc "display RDoc in browser"
task :rdoc_in_browser do
  # Display the rdoc documentation in the system's default browser.
  Launchy.open("#{PROJECT_DIR}/doc/rdoc/index.html")  
end

desc "Regenerate RDoc and display in browser"
task :rerdoc_in_browser => [:rerdoc] do
  # Display the rdoc documentation in the system's default browser.
  Launchy.open("#{PROJECT_DIR}/doc/rdoc/index.html")  
end

#************
# RSpec Tasks
#************

desc "" # undocumented, so won't appear in default raketask list
RSpec::Core::RakeTask.new(:spec_unit) do |t|
  t.rspec_opts = "--tag ~acceptance"
end

desc "run RSpec unit specs (not acceptance)"
task :spec => [:clear_temp, :spec_unit]

desc "" # undocumented, so won't appear in default raketask list
RSpec::Core::RakeTask.new(:spec_acceptance_tests) do |t|
  t.rspec_opts = "--tag acceptance"
end

desc "" # undocumented, so won't appear in default raketask list
RSpec::Core::RakeTask.new(:spec_wp_tests) do |t|
  t.rspec_opts = "--tag wp"
end

desc "run RSpec acceptance specs"
task :spec_acceptance => [:clear_temp, :spec_acceptance_tests]

desc "run RSpec wp specs"
task :spec_wp => [:clear_temp, :spec_wp_tests]

desc "diff the learning of all 24 SL languages (acceptance specs)"
task :spec_diff_sl do
  kdiff3 = "C:/Programs/kdiff3/kdiff3.exe"
  sl_fixture_dir = "#{PROJECT_DIR}/test/fixtures/sl_learning"
  generated_dir = "#{PROJECT_DIR}/temp/sl_learning"
  system "#{kdiff3} #{sl_fixture_dir} #{generated_dir}"
end

desc "run RSpec specs with HTML output"
RSpec::Core::RakeTask.new(:spec_html) do |t|
  t.rspec_opts = "-f html -o temp/rspec_report.html"
end

desc "display all RSpec specs in a browser"
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

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

require File.join(File.dirname(__FILE__), 'lib', 'version')

PKG_NAME      = "capistrano_s3"
PKG_BUILD     = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
PKG_VERSION   = Capistrano_S3::Version::STRING + PKG_BUILD
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

desc "Default task"
task :default => [ :test ]

desc "Build documentation"
task :doc => [ :rdoc ]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir["test/**/*_test.rb"]
  t.verbose = true
end

desc "Run code-coverage analysis using rcov"
task :coverage do
  rm_rf "coverage"
  files = Dir["test/**/*_test.rb"]
  system "rcov --sort coverage -Ilib:test #{files.join(' ')}"
end

GEM_SPEC = eval(File.read("#{File.dirname(__FILE__)}/#{PKG_NAME}.gemspec"))

Rake::GemPackageTask.new(GEM_SPEC) do |p|
  p.gem_spec = GEM_SPEC
  p.need_tar = true
  p.need_zip = true
end

desc "Build the RDoc API documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.title    = "Capistrano_S3 -- Capistrano deployment strategy using Amazon S3"
  rdoc.options += %w(--line-numbers --inline-source --main README)
  rdoc.template = 'html'
  rdoc.rdoc_files.include 'README'
  rdoc.rdoc_files.include 'MIT-LICENSE'
  rdoc.rdoc_files.include 'lib/**/*.rb'
end

desc "Clean up generated directories and files"
task :clean do
  rm_rf "pkg"
  rm_rf "doc"
  rm_rf "coverage"
end

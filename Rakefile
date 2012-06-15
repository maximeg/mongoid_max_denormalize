require "bundler"
Bundler.setup

require "rake"
require "rspec/core/rake_task"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "mongoid/max/denormalize/version"
VERSION = Mongoid::Max::Denormalize::Version::STRING

task :gem => :build
task :build do
  system "gem build mongoid_max_denormalize.gemspec"
end

task :release => :build do
  system "git tag -a #{VERSION} -m 'Version #{VERSION}'"
  system "git push --tags"
  system "gem push mongoid_max_denormalize-#{VERSION}.gem"
end

RSpec::Core::RakeTask.new("spec") do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new('spec:progress') do |spec|
  spec.rspec_opts = %w(--format progress)
  spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec


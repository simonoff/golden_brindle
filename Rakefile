# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
$LOAD_PATH.unshift('lib')
require 'jeweler'
require 'golden_brindle'
Jeweler::Tasks.new do |gem|
  gem.name = "golden_brindle"
  gem.summary = %Q{Unicorn HTTP server multiple application runner tool}
  gem.description = %Q{Unicorn HTTP server multiple application runner tool}
  gem.email = "alex@simonov.me"
  gem.homepage = "http://github.com/simonoff/golden_brindle"
  gem.authors = ["Alexander Simonov"]
  gem.version = GoldenBrindle::Const::VERSION
  gem.license = "GPL2"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

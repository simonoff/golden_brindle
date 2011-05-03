require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  require File.dirname(__FILE__) + "/lib/golden_brindle/const.rb"
  Jeweler::Tasks.new do |gem|
    gem.name = "golden_brindle"
    gem.summary = %Q{Unicorn HTTP server multiple application runner tool}
    gem.description = %Q{Unicorn HTTP server multiple application runner tool}
    gem.email = "alex@simonov.me"
    gem.homepage = "http://github.com/simonoff/golden_brindle"
    gem.authors = ["Alexander Simonov"]
    gem.add_dependency "gem_plugin", ">= 0.2.3"
    gem.add_dependency "unicorn", ">= 1.00"
    gem.version = GoldenBrindle::Const::VERSION
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "golden_brindle #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

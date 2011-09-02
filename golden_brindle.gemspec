# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{golden_brindle}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alexander Simonov"]
  s.date = %q{2011-09-02}
  s.default_executable = %q{golden_brindle}
  s.description = %q{Unicorn HTTP server multiple application runner tool}
  s.email = %q{alex@simonov.me}
  s.executables = ["golden_brindle"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc",
    "TODO"
  ]
  s.files = [
    "COPYING",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "TODO",
    "VERSION",
    "bin/golden_brindle",
    "golden_brindle.gemspec",
    "lib/golden_brindle.rb",
    "lib/golden_brindle/cluster.rb",
    "lib/golden_brindle/command.rb",
    "lib/golden_brindle/configure.rb",
    "lib/golden_brindle/const.rb",
    "lib/golden_brindle/restart.rb",
    "lib/golden_brindle/start.rb",
    "lib/golden_brindle/stop.rb",
    "resources/golden_brindle",
    "test/helper.rb",
    "test/test_golden_brindle.rb"
  ]
  s.homepage = %q{http://github.com/simonoff/golden_brindle}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Unicorn HTTP server multiple application runner tool}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gem_plugin>, [">= 0.2.3"])
      s.add_runtime_dependency(%q<unicorn>, [">= 1.00"])
    else
      s.add_dependency(%q<gem_plugin>, [">= 0.2.3"])
      s.add_dependency(%q<unicorn>, [">= 1.00"])
    end
  else
    s.add_dependency(%q<gem_plugin>, [">= 0.2.3"])
    s.add_dependency(%q<unicorn>, [">= 1.00"])
  end
end


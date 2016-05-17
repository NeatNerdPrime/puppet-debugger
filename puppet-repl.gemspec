# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: puppet-repl 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "puppet-repl"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Corey Osman"]
  s.date = "2016-05-17"
  s.description = "A interactive command line tool for evaluating the puppet language"
  s.email = "corey@nwops.io"
  s.executables = ["prepl"]
  s.extra_rdoc_files = [
    "CHANGELOG.md",
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".travis.yml",
    "CHANGELOG.md",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/prepl",
    "lib/awesome_print/ext/awesome_puppet.rb",
    "lib/puppet-repl.rb",
    "lib/puppet-repl/cli.rb",
    "lib/puppet-repl/support.rb",
    "lib/puppet-repl/support/compiler.rb",
    "lib/puppet-repl/support/environment.rb",
    "lib/puppet-repl/support/errors.rb",
    "lib/puppet-repl/support/facts.rb",
    "lib/puppet-repl/support/functions.rb",
    "lib/puppet-repl/support/input_responders.rb",
    "lib/puppet-repl/support/node.rb",
    "lib/puppet-repl/support/play.rb",
    "lib/puppet-repl/support/scope.rb",
    "lib/trollop.rb",
    "lib/version.rb",
    "puppet-repl.gemspec",
    "spec/fixtures/environments/production/manifests/site.pp",
    "spec/fixtures/invalid_node_obj.yaml",
    "spec/fixtures/node_obj.yaml",
    "spec/fixtures/sample_manifest.pp",
    "spec/prepl_spec.rb",
    "spec/puppet-repl_spec.rb",
    "spec/spec_helper.rb",
    "spec/support_spec.rb"
  ]
  s.homepage = "http://github.com/nwops/puppet-repl"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "A repl for the puppet language"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<puppet>, [">= 3.8"])
      s.add_runtime_dependency(%q<facterdb>, ["~> 0.3"])
      s.add_runtime_dependency(%q<awesome_print>, ["~> 1.6"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
    else
      s.add_dependency(%q<puppet>, [">= 3.8"])
      s.add_dependency(%q<facterdb>, ["~> 0.3"])
      s.add_dependency(%q<awesome_print>, ["~> 1.6"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
    end
  else
    s.add_dependency(%q<puppet>, [">= 3.8"])
    s.add_dependency(%q<facterdb>, ["~> 0.3"])
    s.add_dependency(%q<awesome_print>, ["~> 1.6"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
  end
end

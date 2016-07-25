# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ragabash/version"

Gem::Specification.new do |spec|
  spec.name          = "ragabash"
  spec.version       = Ragabash::VERSION
  spec.authors       = ["Tim Bellefleur"]
  spec.email         = ["nomoon@phoebus.ca"]

  spec.summary       = "A collection of useful extensions, refinements, and tools."
  spec.homepage      = "https://github.com/nomoon/ragabash"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 2.2"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 11.2"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.6"
  spec.add_development_dependency "rubocop", "~> 0.41"
  spec.add_development_dependency "rubocop-rspec", "~> 1.5.1"
  spec.add_development_dependency "yard", "~> 0.9"

  spec.add_runtime_dependency "ice_nine", "~> 0.11"
  spec.add_runtime_dependency "awesome_print", "~> 1.7"
  spec.add_runtime_dependency "rouge", "~> 2.0"
  spec.add_runtime_dependency "pry", "~> 0.10.4"
end

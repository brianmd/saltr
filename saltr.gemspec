# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'saltr/version'

Gem::Specification.new do |spec|
  spec.name          = "saltr"
  spec.version       = Saltr::VERSION
  spec.authors       = ['Brian Murphy-Dye']
  spec.email         = ['brian@murphydye.com']

  spec.summary       = %q{REPL wrapper for salt.}
  spec.description   = %q{}
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = ['saltr']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard'
end

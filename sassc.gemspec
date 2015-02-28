# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sassc/version'

Gem::Specification.new do |spec|
  spec.name          = "sassc"
  spec.version       = SassC::VERSION
  spec.authors       = ["Ryan Boland"]
  spec.email         = ["bolandryanm@gmail.com"]
  spec.summary       = "Use Libsass with Ruby!"
  spec.description   = "Use Libsass with Ruby!"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "ext"]

  spec.extensions    = ["Rakefile"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.5.1"
  spec.add_development_dependency "minitest-around"
  spec.add_development_dependency "test_construct"

  spec.add_dependency "ffi", "~> 1.9.6"
end

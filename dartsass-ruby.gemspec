# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sassc/version'

Gem::Specification.new do |spec|
  spec.name          = 'dartsass-ruby'
  spec.version       = SassC::VERSION
  spec.authors       = ['Ryan Boland', 'なつき', 'Johnny Shields']
  spec.email         = ['ryan@tanookilabs.com', 'i@ntk.me']
  spec.summary       = 'Use Dart Sass with Ruby and Sprockets'
  spec.description   = 'Use Dart Sass with Ruby and Sprockets'
  spec.homepage      = 'https://github.com/tablecheck/dartsass-ruby'
  spec.license       = 'MIT'
  spec.metadata      = {
    'documentation_uri' => "https://rubydoc.info/gems/#{spec.name}/#{spec.version}",
    'source_code_uri' => "#{spec.homepage}/tree/v#{spec.version}"
  }

  spec.files = Dir['lib/**/*.rb'] + %w[LICENSE README.md]
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.required_ruby_version = '>= 2.6.0'

  spec.add_runtime_dependency 'sass-embedded', '~> 1.54'

  spec.add_development_dependency 'minitest', '~> 5.16.0'
  spec.add_development_dependency 'minitest-around', '~> 0.5.0'
  spec.add_development_dependency 'rake', '>= 10.0.0'
  spec.add_development_dependency 'rubocop', '~> 1.37.0'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.22.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.15.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
end

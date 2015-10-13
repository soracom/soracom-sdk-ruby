# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soracom/version'

Gem::Specification.new do |spec|
  spec.name          = 'soracom'
  spec.version       = Soracom::VERSION
  spec.authors       = ['MATSUI, Motokatsu']
  spec.email         = ['j3tm0t0@gmail.com']

  spec.summary       = 'SORACOM API Client library and tool'
  spec.description   = 'SORACOM provides sets of APIs to control their IoT platform service. This gem package will let you call SORACOM API either via command line interface or Ruby program.'
  spec.homepage      = 'https://github.com/soracom/soracom-sdk-ruby/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|pkg)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'

  spec.add_dependency 'thor'
  spec.add_dependency 'io-console'
end

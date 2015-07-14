# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simatic/version'

Gem::Specification.new do |spec|
  spec.name          = "simatic"
  spec.version       = Simatic::VERSION
  spec.authors       = ["Konstantin Ryzhov"]
  spec.email         = ["konstantin.ryzhov@gmail.com"]

  spec.summary       = %q{Ruby library for Siemens Simatic S7-300 PLC data exchange.}
  spec.description   = %q{Ruby library for Siemens Simatic S7-300 PLC data exchange.}
  spec.homepage      = "https://github.com/konstantin-ryzhov/ruby_s7plc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ['read']
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  end

  spec.add_development_dependency "bundler", "~> 1.9"
  # spec.add_development_dependency "rake", "~> 10.0"
end

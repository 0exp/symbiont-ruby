# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'symbiont/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.2.7'

  spec.name          = 'symbiont-ruby'
  spec.version       = Symbiont::VERSION
  spec.author        = 'Rustam Ibragimov'
  spec.email         = 'iamdaiver@icloud.com'
  spec.summary       = 'Evaluate proc-objects in many contexts simultaneously'
  spec.description   = 'Symbiont is a cool implementation of proc-objects execution algorithm: ' \
                       'in the context of other object, but with the preservation of ' \
                       'the closed environment of the proc object and with the ability of ' \
                       'control the method dispatch inside it. A proc object is executed in ' \
                       'three contexts: in the context of required object, in the context of '\
                       'a closed proc\'s environment and in the global (Kernel) context.'

  spec.homepage      = 'https://github.com/0exp/symbiont-ruby'
  spec.license       = 'MIT'
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|features)/})
  end

  spec.add_development_dependency 'rspec',          '~> 3.7'
  spec.add_development_dependency 'rubocop',        '~> 0.57'
  spec.add_development_dependency 'rubocop-rspec',  '~> 1.26'
  spec.add_development_dependency 'simplecov',      '~> 0.15'
  spec.add_development_dependency 'simplecov-json', '~> 0.2'
  spec.add_development_dependency 'coveralls',      '~> 0.7'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'yard'
end

# frozen_string_literal: true

require 'simplecov'
require 'simplecov-json'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start { add_filter 'spec' }

require 'bundler/setup'
require 'symbiont'
require 'pry'

require_relative 'support/spec_support'
require_relative 'support/shared_contexts'

RSpec.configure do |config|
  config.order = :random
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.include SpecSupport::FakeDataGenerator
  config.extend  SpecSupport::FakeDataGenerator
end

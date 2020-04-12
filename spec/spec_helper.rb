# frozen_string_literal: true

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.minimum_coverage(100)
SimpleCov.start do
  enable_coverage :branch
  add_filter 'spec'
end

require 'bundler/setup'
require 'symbiont'
require 'pry'

require_relative 'support/spec_support'
require_relative 'support/shared_contexts'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed

  config.include SpecSupport::SymbiontHelpers
  config.include SpecSupport::FakeDataGenerator
  config.extend  SpecSupport::FakeDataGenerator
end

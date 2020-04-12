# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop'
require 'rubocop/rake_task'
require 'rubocop-rails'
require 'rubocop-performance'
require 'rubocop-rspec'
require 'rubocop-rake'
require 'yard'

RuboCop::RakeTask.new(:rubocop) do |t|
  config_path = File.expand_path(File.join('.rubocop.yml'), __dir__)
  t.options = ['--config', config_path]
  t.requires << 'rubocop-rspec'
  t.requires << 'rubocop-performance'
  t.requires << 'rubocop-rake'
end

RSpec::Core::RakeTask.new(:rspec)

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = Dir[Pathname.new(__FILE__).join('../lib/**/*.rb')]
  t.options = %w[--protected --private]
end

task default: :rspec

desc 'Code documentation coverage check'
task yardoc: :doc do
  undocumented_code_objects = YARD::Registry.tap(&:load).select do |code_object|
    code_object.docstring.empty?
  end

  if undocumented_code_objects.empty?
    puts 'YARD COVERAGE [SUCCESS] => 100% documentation coverage!'
  else
    failing_code_objects = undocumented_code_objects.map do |code_object|
      "- #{code_object.class} => #{code_object}"
    end.join("\n")

    abort("YARD COVERAGE [FAILURE] => No documentation found for: \n #{failing_code_objects}")
  end
end

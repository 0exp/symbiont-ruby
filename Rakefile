# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:rspec)

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = Dir[Pathname.new(__FILE__).join('../lib/**/*.rb')]
  t.options = %w[--protected --private]
end

task default: :rspec

task yardoc: :doc do
  undocumented_code_objects = YARD::Registry.tap(&:load).select do |code_object|
    code_object.docstring.empty?
  end

  if undocumented_code_objects.empty?
    puts 'YARD COVERAGE [SUCCESS] => 100% documentation coverage!'
  else
    failing_code_objects = undocumented_code_objects.map do |code_object|
      "- #{code_object.class} => #{code_object.to_s}"
    end.join("\n")

    abort("YARD COVERAGE [FAILURE] => No documentation found for: \n #{failing_code_objects}")
  end
end

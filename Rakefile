#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:all) do |config|
    options  = %w(--color)
    options += %w(--format documentation)
    options += %w(--format html --out spec/reports/unit-test-report.html)

    config.rspec_opts = options
  end
end

task default: %w(spec:all)

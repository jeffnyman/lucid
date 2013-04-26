# encoding: utf-8
require "bundler/gem_tasks"

$:.unshift(File.dirname(__FILE__) + '/lib')
Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

task :release => 'api:doc'
task :default => [:spec, :cucumber]

require 'rake/clean'
CLEAN.include %w(**/*.{log,pyc,rbc,tgz} doc)

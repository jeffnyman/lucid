require 'spec_helper'
require 'lucid/spec_builder'
require 'gherkin/formatter/model'

module Lucid
  module CLI
    describe App do

      let(:args)   { [] }
      let(:stdin)  { StringIO.new }
      let(:stdout) { StringIO.new }
      let(:stderr) { StringIO.new }
      let(:kernel) { double(:kernel) }
      subject { App.new(args, stdin, stdout, stderr, kernel) }

      describe 'start' do
        context 'passed a runtime' do
          let(:runtime) { double('runtime').as_null_object }

          def do_start
            subject.start!(runtime)
          end

          it 'configures the runtime' do
            configuration = double('Configuration').as_null_object
            Configuration.stub(:new => configuration)
            runtime.should_receive(:configure).with(configuration)
            kernel.should_receive(:exit).with(1)
            do_start
          end

          it 'uses that runtime for running and reporting results' do
            results = double('results', :failure? => true)
            runtime.should_receive(:execute)
            runtime.stub(:results).and_return(results)
            kernel.should_receive(:exit).with(1)
            do_start
          end
        end

        context 'execution is interrupted' do
          after do
            Lucid.wants_to_quit = false
          end

          it 'should register as a failure' do
            results = double('results', :failure? => false)
            runtime = ContextLoader.any_instance
            runtime.stub(:excute)
            runtime.stub(:results).and_return(results)

            Lucid.wants_to_quit = true
            kernel.should_receive(:exit).with(1)
            subject.start!
          end
        end
      end

      describe 'verbose execution' do
        before(:each) do
          b = Lucid::Parser::SpecBuilder.new('specs/test.spec')
          b.feature(Gherkin::Formatter::Model::Feature.new([], [], 'Feature', 'Testing', '', 99, ''))
          b.language = double
          @empty_feature = b.result
        end

        it 'should show the spec files that were parsed' do
          cli = App.new(%w{--verbose test.spec}, stdin, stdout, stderr, kernel)
          cli.stub(:require)

          Lucid::SpecFile.stub(:new).and_return(double('spec file', :parse => @empty_feature))
          kernel.should_receive(:exit).with(0)

          cli.start!

          stdout.string.should include('test.spec')
        end
      end

    end
  end
end

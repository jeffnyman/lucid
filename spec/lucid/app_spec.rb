require_relative '../spec_helper'

module Lucid
  module CLI
    describe App do
      
      let(:args)   { [] }
      let(:stdin)  { StringIO.new }
      let(:stdout) { StringIO.new }
      let(:stderr) { StringIO.new }
      let(:kernel) { double(:kernel) }
      subject { App.new(args, stdin, stdout, stderr, kernel) }
      
      describe "start" do
        context "passed a runtime" do
          let(:runtime) { double('runtime').as_null_object }
          
          def do_start
            subject.start(runtime)
          end
          
          it "configures the runtime" do
            configuration = double('Configuration').as_null_object
            Configuration.stub(:new => configuration)
            runtime.should_receive(:configure).with(configuration)
            kernel.should_receive(:exit).with(1)
            do_start
          end
          
          it "uses that runtime for running and reporting results" do
            results = double('results', :failure? => true)
            runtime.should_receive(:run)
            runtime.stub(:results).and_return(results)
            kernel.should_receive(:exit).with(1)
            do_start
          end
        end
      end
      
    end
  end
end
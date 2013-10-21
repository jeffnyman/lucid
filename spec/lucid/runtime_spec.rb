require_relative '../spec_helper'

module Lucid
  describe Runtime do

    let(:options) { {} }
    subject { Runtime.new(options) }

    describe '#specs_paths' do
      let(:options) { {:paths => ['specs/area1/test.spec', 'specs/area1/area2/test.spec', 'others_specs'] } }

      it 'returns the value from the configuration.spec_source' do
        subject.specs_paths.should == options[:spec_source]
      end
    end

    describe '#configure' do
      let(:orchestrator) { double(Runtime::Orchestrator).as_null_object }
      let(:results) { double(Runtime::Results).as_null_object }
      let(:new_config) { double('New Configuration') }

      before(:each) do
        Runtime::Orchestrator.stub(:new => orchestrator)
        Runtime::Results.stub(:new => results)
      end

      it 'tells the orchestrator and results about the new configuration' do
        orchestrator.should_receive(:configure).with(new_config)
        results.should_receive(:configure).with(new_config)
        subject.configure(new_config)
      end

      it '#doc_string' do
        subject.doc_string('Testing').should == 'Testing'
      end
    end
  end
end
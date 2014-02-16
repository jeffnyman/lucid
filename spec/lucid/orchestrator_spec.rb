require 'spec_helper'

module Lucid
  describe ContextLoader::Orchestrator do
    let(:options) { {} }
    let(:interface) { double('interface') }
    subject { ContextLoader::Orchestrator.new(interface, options) }

    let(:dsl) do
      @rb = subject.load_code_language('rb')
      Object.new.extend(InterfaceRb::RbLucid)
    end

    it 'should format step names' do
      dsl.Given(/it (.*) in (.*)/) { |what, month| }
      dsl.Given(/some other phrase/) { |what, month| }

      format = subject.step_match('it works in lucid').format_args('[%s]')
      format.should == 'it [works] in [lucid]'
    end

    it 'should cache step match results' do
      dsl.Given(/it (.*) in (.*)/) { |what, month| }
      step_match = subject.step_match('it works in lucid')
      @rb.should_not_receive :step_matches
      second_step_match = subject.step_match('it works in lucid')
      step_match.should equal(second_step_match)
    end


    describe 'resolving test definition matches' do
      it 'should raise Undefined error when no test definitions match' do
        lambda do
          subject.step_match('Simple Lucid Test')
        end.should raise_error(Undefined)
      end

      it 'should raise Ambiguous error with guess hint when multiple test definitions match' do
        expected_error = %{Ambiguous match of "Simple Lucid Test":

spec/lucid/orchestrator_spec.rb:\\d+:in `/Simple (.*) Test/'
spec/lucid/orchestrator_spec.rb:\\d+:in `/Simple Lucid (.*)/'

You can run again with --guess to make Lucid be a little more smart about it.
}
        dsl.Given(/Simple (.*) Test/) {|app|}
        dsl.Given(/Simple Lucid (.*)/) {|action|}

        lambda do
          subject.step_match("Simple Lucid Test")
        end.should raise_error(Ambiguous, /#{expected_error}/)
      end

      describe 'when --guess is used' do
        let(:options) { {:guess => true} }

        it 'should not show --guess hint' do
          expected_error = %{Ambiguous match of "Simple lucid test":

spec/lucid/orchestrator_spec.rb:\\d+:in `/Simple (.*)/'
spec/lucid/orchestrator_spec.rb:\\d+:in `/Simple (.*)/'

}
          dsl.Given(/Simple (.*)/) {|phrase|}
          dsl.Given(/Simple (.*)/) {|phrase|}

          lambda do
            subject.step_match('Simple lucid test')
          end.should raise_error(Ambiguous, /#{expected_error}/)
        end

        it 'should pick right test definition when an equal number of capture groups' do
          right = dsl.Given(/Simple (.*) test/) {|app|}
          wrong = dsl.Given(/Simple (.*)/) {|phrase|}

          subject.step_match('Simple lucid test').step_definition.should == right
        end

        it 'should pick right test definition when an unequal number of capture groups' do
          right = dsl.Given(/Simple (.*) test ran (.*)/) {|app|}
          wrong = dsl.Given(/Simple (.*)/) {|phrase|}

          subject.step_match('Simple lucid test ran well').step_definition.should == right
        end

        it 'should pick most specific test definition when an unequal number of capture groups' do
          general       = dsl.Given(/Simple (.*) test ran (.*)/) {|app|}
          specific      = dsl.Given(/Simple lucid test ran well/) do; end
          more_specific = dsl.Given(/^Simple lucid test ran well$/) do; end

          subject.step_match('Simple lucid test ran well').step_definition.should == more_specific
        end

        it 'should not raise Ambiguous error when multiple test definitions match' do
          dsl.Given(/Simple (.*) test/) {|app|}
          dsl.Given(/Simple (.*)/) {|phrase|}

          lambda do
            subject.step_match('Simple lucid test')
          end.should_not raise_error
        end

        it 'should not raise NoMethodError when guessing from multiple test definitions with nil fields' do
          dsl.Given(/Simple (.*) test( cannot run well)?/) {|app, status|}
          dsl.Given(/Simple (.*)?/) {|phrase|}

          lambda do
            subject.step_match('Simple lucid test')
          end.should_not raise_error
        end

      end

    end

  end
end

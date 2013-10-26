require_relative '../spec_helper'

module Lucid
  module InterfaceRb
    describe RbStepDefinition do
      let(:interface) { double('interface') }
      let(:orchestrator) { Lucid::Runtime::Orchestrator.new(interface) }
      let(:rb) { orchestrator.load_code_language('rb') }
      let(:dsl) do
        rb
        Object.new.extend(Lucid::InterfaceRb::RbLucid)
      end

      before do
        rb.before(double('scenario').as_null_object)
        $inside = nil
      end

      def run_step(text)
        orchestrator.step_match(text).invoke(nil)
      end
      
      it 'should allow calling of other steps' do
        dsl.Given /Outside/ do
          step 'Inside'
        end
        dsl.Given /Inside/ do
          $inside = true
        end

        run_step 'Outside'
        $inside.should == true
      end

      it 'should allow calling of other steps with inline arg' do
        dsl.Given /Outside/ do
          step 'Inside', Lucid::AST::Table.new([['inside']])
        end

        dsl.Given /Inside/ do |table|
          $inside = table.raw[0][0]
        end

        run_step 'Outside'
        $inside.should == 'inside'
      end

      context 'mapping to domain methods' do
        it 'should call a method on the domain when specified with a symbol' do
          rb.current_domain.should_receive(:with_symbol)
          dsl.Given /With symbol/, :with_symbol
          run_step 'With symbol'
        end

        it 'should call a method on a specified object' do
          target = double('target')
          rb.current_domain.stub(:target => target)
          dsl.Given /With symbol on block/, :with_symbol, :on => lambda { target }

          target.should_receive(:with_symbol)
          run_step 'With symbol on block'
        end

        it 'should call a method on a specified domain attribute' do
          target = double('target')
          rb.current_domain.stub(:target => target)
          dsl.Given /With symbol on symbol/, :with_symbol, :on => :target

          target.should_receive(:with_symbol)
          run_step 'With symbol on symbol'
        end
      end

      it 'should raise Undefined when inside step is not defined' do
        dsl.Given /Outside/ do
          step 'Inside'
        end

        lambda { run_step 'Outside' }.should raise_error(Lucid::Undefined, 'Undefined step: "Inside"')
      end

      it 'should allow forced pending' do
        dsl.Given /Outside/ do
          pending('This needs to be tested.')
        end

        lambda { run_step 'Outside' }.should raise_error(Lucid::Pending, 'This needs to be tested.')
      end

      it 'should allow puts' do
        interface.should_receive(:puts).with('testing')
        dsl.Given /Say Something/ do
          puts 'testing'
        end
        run_step 'Say Something'
      end

      it 'should recognize $arg style captures' do
        arg_value = 'testing'
        dsl.Given 'capture this: $arg' do |arg|
          arg.should == arg_value
        end
        run_step 'capture this: testing'
      end

      it 'should have a JSON representation of the signature' do
        RbStepDefinition.new(rb, /There are (\d+) Lucid tests/i, lambda{}, {}).to_hash.should == {'source' => "There are (\\d+) Lucid tests", 'flags' => 'i'}
      end

      it 'should raise ArityMismatchError when the number of capture groups differs from the number of step arguments' do
        dsl.Given /No group: \w+/ do |arg|
        end

        lambda { run_step 'No group: arg' }.should raise_error(Lucid::ArityMismatchError)
      end

      it 'should not allow modification of args since it messes up nice formatting' do
        dsl.Given /Lucid tests are (.*)/ do |status|
          status << 'good'
        end

        lambda { run_step 'Lucid tests are good' }.should raise_error(RuntimeError, /can't modify frozen String/i)
      end
      
    end
  end
end
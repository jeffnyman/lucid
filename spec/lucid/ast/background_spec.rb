require 'spec_helper'

require 'lucid/ast'
require 'lucid/interface_rb/rb_language'

module Lucid
  module AST
    describe Background do

      let(:language) { double.as_null_object }

      before do
        extend(Lucid::InterfaceRb::RbLucid)
        @runtime = Lucid::Runtime.new
        @rb = @runtime.load_code_language('rb')

        $x = $y = nil
        Before do
          $x = 2
        end
        Given /y is (\d+)/ do |n|
          $y = $x * n.to_i
        end

        @visitor = Walker.new(@runtime)

        @feature = double('feature', :visit? => true, :feature_elements => []).as_null_object
      end

      it 'should execute Before blocks before background steps' do
        background = Background.new(
            language,
            Location.new('test.spec', 2),
            comment = Comment.new(''),
            keyword = '',
            title = '',
            description = '',
            steps = [
                Step.new(language,Location.new('test.spec', 7), "Given", "y is 5")
            ]
        )

        scenario = Scenario.new(
            language,
            background,
            comment = Comment.new(''),
            tags = Tags.new(98,[]),
            feature_tags = Tags.new(1,[]),
            line = 99,
            keyword = '',
            title = '',
            description = '',
            steps=[]
        )

        background.feature = @feature
        background.accept(@visitor)
        $x.should == 2
        $y.should == 10
      end

      describe 'should respond to #name' do
        it 'with a value' do
          background = Background.new(
              language,
              Location.new('test.spec', 2),
              comment = Comment.new(''),
              keyword = '',
              title = 'background name',
              description = '',
              steps=[]
          )

          lambda{ background.name }.should_not raise_error
          background.name.should == 'background name'
        end

        it 'without a value' do
          background = Background.new(
              language,
              comment = Comment.new(''),
              line = 2,
              keyword = '',
              title = '',
              description = '',
              steps=[]
          )

          lambda{ background.name }.should_not raise_error
        end
      end

      describe 'failures in a Before hook' do
        before do
          Before do
            raise Exception, 'Exception from Before hook'
          end
        end

        it 'should state that the background has failed' do
          background = Background.new(
              language,
              Location.new('test.spec', 2),
              comment = Comment.new(''),
              keyword = '',
              title = '',
              description = '',
              steps = [
                  Step.new(language, Location.new('test.spec', 7), "Given", "y is 5")
              ]
          )

          background.feature = @feature

          @visitor.should_receive( :visit_exception ) do |exception, status|
            exception.should be_instance_of( Exception )
            exception.message.should == "Exception from Before hook"
            status.should == :failed
          end

          lambda{ background.accept(@visitor) }.should_not raise_error
          background.should be_failed
        end
      end

    end
  end
end
require 'spec_helper'
require 'lucid/ast/tdl_factory'

module Lucid
  module AST
    describe Feature do
      include TDLFactory

      it 'should convert to a symbolic expression' do
        runtime = Lucid::ContextLoader.new
        runtime.load_code_language('rb')
        dsl = Object.new
        dsl.extend Lucid::InterfaceRb::RbLucid

        feature = create_feature(dsl)
        if Lucid::WINDOWS
          feature_file_path = 'specs\\test.spec'
        else
          feature_file_path = 'specs/test.spec'
        end

        feature.to_sexp.should ==
            [
                :feature,
                feature_file_path,
                'Testing TDL',
                [:comment, "# Feature Comment Line\n"],
                [:tag, 'smoke'],
                [:tag, 'critical'],
                [:background, 2, 'Background:',
                 [:step, 3, 'Given', 'a passing step']],
                [:scenario, 9, 'Scenario:',
                 'Test Scenario',
                 [:comment, "   # Scenario Comment Line 1 \n# Scenario Comment Line 2 \n"],
                 [:tag, 'regression'],
                 [:tag, 'selenium'],
                 [:step_invocation, 3, 'Given', 'a passing step'],
                 [:step_invocation, 10, 'Given', 'a passing step with an inline argument:',
                  [:table,
                   [:row, -1,
                    [:cell, '1'], [:cell, '22'], [:cell, '333']],
                   [:row, -1,
                    [:cell, '4444'], [:cell, '55555'], [:cell, '666666']]]],
                 [:step_invocation, 11, 'Given', 'a working step with an inline argument:',
                  [:doc_string, "\n Testing with\nLucid tools\n"]],
                 [:step_invocation, 12, 'Given', 'a non-passing step']]
            ]
      end

      it 'should store operating system specific file paths' do
        runtime = Lucid::ContextLoader.new
        runtime.load_code_language('rb')
        dsl = Object.new
        dsl.extend Lucid::InterfaceRb::RbLucid
        feature = create_feature(dsl)

        if Lucid::WINDOWS
          feature.file.should == 'specs\test.spec'
        else
          feature.file.should == 'specs/test.spec'
        end
      end

    end
  end
end

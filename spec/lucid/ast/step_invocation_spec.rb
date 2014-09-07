require 'spec_helper'
require 'lucid/ast/step_invocation'

module Lucid
  module AST
    describe StepInvocation do
      let(:step_invocation) do
        matched_cells = []
        StepInvocation.new(double, double, double, matched_cells)
      end

      describe 'filtering backtraces' do
        context 'when enabled' do
          before { allow(Lucid).to receive(:use_full_backtrace).and_return(false) }

          it "removes lines with 'gems' in the path" do
            original_backtrace = ['/foo/bar/gems/baz', '/path/to/my/file.rb']
            exception = StandardError.new
            exception.set_backtrace(original_backtrace)
            result = step_invocation.filter_backtrace(exception).backtrace
            expect(result).to eq(['/path/to/my/file.rb'])
          end

          it "removes lines with '.gem' in the path" do
            original_backtrace = ['/foo/bar/.gem/baz', '/path/to/my/file.rb']
            exception = StandardError.new
            exception.set_backtrace(original_backtrace)
            result = step_invocation.filter_backtrace(exception).backtrace
            expect(result).to eq(['/path/to/my/file.rb'])
          end
        end

        context 'when disabled' do
          before { allow(Lucid).to receive(:use_full_backtrace).and_return(true) }

          it 'return the exception unmodified' do
            exception = double
            expect(step_invocation.filter_backtrace(exception)).to eq(exception)
          end
        end
      end

    end
  end
end

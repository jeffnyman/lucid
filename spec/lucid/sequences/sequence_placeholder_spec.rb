require_relative '../../spec_helper'
require_relative '../../../lib/lucid/sequence/sequence_template'

module Sequence
  module SequenceTemplate
    
    describe Placeholder do
      subject { Placeholder.new('testing') }

      context 'establishing a placeholder' do
        it 'should be created with a variable name' do
          expect { Placeholder.new('testing') }.not_to raise_error
        end

        it 'should know the name of its variable' do
          expect(subject.name).to eq('testing')
        end
      end
      
      context 'generating a placeholder' do
        it 'should generate an empty string when an actual value is absent' do
          generated_text = subject.output(Object.new, {})
          expect(generated_text).to be_empty

          generated_text = subject.output(Object.new, { 'testing' => nil })
          expect(generated_text).to be_empty
        end

        it 'should generate an empty string when the context object value is absent' do
          context = Object.new
          def context.testing
            nil
          end
          generated_text = subject.output(context, {})
          expect(generated_text).to be_empty
        end

        it 'should render the actual value bound to the placeholder' do
          generated_text = subject.output(Object.new, { 'testing' => 'test' })
          expect(generated_text).to eq('test')
        end

        it 'should render the context object actual value bound to the placeholder' do
          context = Object.new
          def context.testing
            'test'
          end
          generated_text = subject.output(context, {})
          expect(generated_text).to eq('test')
        end
        
      end
    end
    
  end
end
require_relative '../../spec_helper'
require_relative '../../../lib/lucid/sequence/sequence_template'

module Sequence
  module SequenceTemplate

    describe ConditionalSection do

      context 'establishing a conditional section' do
        it 'should be created with a variable name and a boolean' do
          expect { ConditionalSection.new('testing', false) }.not_to raise_error
          expect { ConditionalSection.new('testing', true) }.not_to raise_error
        end

        it 'should know whether to generated based on the existence of an actual value' do
          [false, true].each do |existence|
            instance = ConditionalSection.new('testing', existence)
            expect(instance.existence).to eq(existence)
          end
        end
      end
      
      context 'generating a conditional section' do
        let(:example_child_elements) do
          [ StaticText.new('Test '),
            Placeholder.new('content'),
            EOLine.new
          ]
        end

        subject { ConditionalSection.new('testing', true) }

        it 'should know its original source text' do
          expect(subject.to_s).to eq('<?testing>')
        end

        it 'should generate the children when conditions are met' do
          example_child_elements.each { |child| subject.add_child(child) }

          locals = { 'content' => 'found', 'testing' => 'exists' }
          generated_text = subject.output(Object.new, locals)
          expected_text = "Test found\n"
          expect(generated_text).to eq(expected_text)
        end
        
        it 'should generate the children even when value does not exist' do
          instance = ConditionalSection.new('testing', false)
          example_child_elements.each { |child| instance.add_child(child) }
          locals = { 'content' => 'found' }
          generated_text = instance.output(Object.new, locals)
          expected_text = "Test found\n"
          expect(generated_text).to eq(expected_text)
        end

        it "should generate nothing when conditions are not met" do
          example_child_elements.each { |child| subject.add_child(child) }

          locals = { 'content' => 'found' }
          generated_text = subject.output(Object.new, locals)
          expect(generated_text).to eq('')

          instance = ConditionalSection.new('testing', false)
          example_child_elements.each { |child| instance.add_child(child) }

          locals = { 'content' => 'found', 'testing' => 'exists' }
          generated_text = instance.output(Object.new, locals)
          expect(generated_text).to eq('')
        end
      end
      
    end
    
  end
end

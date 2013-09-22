require_relative '../../spec_helper'
require_relative '../../../lib/lucid/sequence/sequence_template'

module Sequence
  module SequenceTemplate
    
    describe Section do
      subject { Section.new('testing') }

      let(:example_child_elements) do
        [ StaticText.new('Test '),
          Placeholder.new('content'),
          EOLine.new
        ]
      end

      context 'establishing a section' do
        it 'should be created with a variable name' do
          expect { Section.new('testing') }.not_to raise_error
        end

        it 'should know the name of its variable' do
          expect(subject.name).to eq('testing')
        end

        it 'should have no child elements by default' do
          expect(subject).to have(0).children
        end
      end

      context 'generating a section' do
        it 'should add child elements' do
          example_child_elements.each do |child|
            subject.add_child(child)
          end

          expect(subject.children).to eq(example_child_elements)
        end

        it 'should know the names of all child placeholders' do
          example_child_elements.each { |child| subject.add_child(child) }
          expect(subject.variables).to eq([ 'content' ])
          
          parent = Section.new('added')
          [ subject,
            StaticText.new('Content '),
            Placeholder.new('tested'),
            EOLine.new
          ].each { |child| parent.add_child(child) }
          expect(parent.variables).to eq(%w(content tested))
        end

        it 'should expect that its subclasses generate the children elements' do
          msg = 'Method Section.output must be implemented in subclass.'
          expect { subject.send(:output, Object.new, {}) }.to raise_error(NotImplementedError, msg)
        end
      end
    end
    
  end
end
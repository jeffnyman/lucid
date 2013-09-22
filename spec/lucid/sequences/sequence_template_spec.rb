require_relative '../../spec_helper'
require_relative '../../../lib/lucid/sequence/sequence_template'

module Sequence
  module SequenceTemplate
    
    describe Engine do

      let(:example_template) do
        example = <<-EXAMPLE
          Given the login page
          When  the username is "<user_name>"
          And   the password is "<password>"
          And   login is clicked
        EXAMPLE
      end

      subject { Engine.new(example_template) }
      
      context 'parsing' do
        def strip_chevrons(text)
          text.gsub(/^<|>$/, '')
        end
        
        it 'should parse an empty text line' do
          expect(Engine.parse('')).to be_empty
        end

        it 'should parse a text line without a parameter' do
          sample_text = 'a TDL statement'
          result = Engine.parse(sample_text)

          expect(result).to have(1).items
          expect(result[0]).to eq([:static, sample_text])
        end

        it 'should parse a text line that consists of only a parameter' do
          sample_text = '<some_parameter>'
          result = Engine.parse(sample_text)

          expect(result).to have(1).items
          expect(result[0]).to eq([:dynamic, strip_chevrons(sample_text)])
        end

        it 'should parse a text line with a parameter at the start' do
          sample_text = '<some_parameter> in a TDL statement'
          result = Engine.parse(sample_text)

          expect(result).to have(2).items
          expect(result[0]).to eq([:dynamic, 'some_parameter'])
          expect(result[1]).to eq([:static,  ' in a TDL statement'])
        end

        it 'should parse a text line with a parameter at the end' do
          sample_text = 'a TDL statement with <some_parameter>'
          result = Engine.parse(sample_text)

          expect(result).to have(2).items
          expect(result[0]).to eq([:static,  'a TDL statement with '])
          expect(result[1]).to eq([:dynamic, 'some_parameter'])
        end

        it 'should parse a text line with a parameter in the middle' do
          sample_text = 'a TDL statement with <some_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result).to have(3).items
          expect(result[0]).to eq([:static,  'a TDL statement with '])
          expect(result[1]).to eq([:dynamic, 'some_parameter'])
          expect(result[2]).to eq([:static,  ' in it'])
        end

        it 'should parse a text line with two separated parameters' do
          sample_text = 'TDL with <one_parameter> and with <another_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result).to have(5).items
          expect(result[0]).to eq([:static ,  'TDL with '])
          expect(result[1]).to eq([:dynamic, 'one_parameter'])
          expect(result[2]).to eq([:static , ' and with '])
          expect(result[3]).to eq([:dynamic, 'another_parameter'])
          expect(result[4]).to eq([:static,  ' in it'])
        end

        it 'should parse a text line with two consecutive parameters' do
          sample_text = 'TDL with <one_parameter> <another_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result).to have(5).items
          expect(result[0]).to eq([:static,  'TDL with '])
          expect(result[1]).to eq([:dynamic, 'one_parameter'])
          expect(result[2]).to eq([:static,  ' '])
          expect(result[3]).to eq([:dynamic, 'another_parameter'])
          expect(result[4]).to eq([:static,  ' in it'])
        end

        it 'should parse a text line with escaped chevrons' do
          sample_text = 'A TDL \<parameter\> is escaped'
          result = Engine.parse(sample_text)
          
          expect(result).to have(1).items
          expect(result[0]).to eq([:static, sample_text])
        end

        it 'should parse a text line with escaped chevrons in a parameter' do
          sample_text = 'A TDL with <some_\<\\>escaped\>_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result).to have(3).items
          expect(result[0]).to eq([:static,  'A TDL with '])
          expect(result[1]).to eq([:dynamic, 'some_\<\\>escaped\>_parameter'])
          expect(result[2]).to eq([:static,  ' in it'])
        end

        it 'should indicate if a parameter has a missing closing chevron' do
          sample_text = 'A TDL with <some_parameter that is malformed'
          error_message = "Missing closing chevron '>'."
          expect { Engine.parse(sample_text) }.to raise_error(StandardError, error_message)
        end

        it 'should indicate if a parameter has a missing opening chevron' do
          sample_text = 'A TDL with some_parameter> that is malformed'
          error_message = "Missing opening chevron '<'."
          expect { Engine.parse(sample_text) }.to raise_error(StandardError, error_message)
        end

        it 'should indicate if a text has nested opening chevrons' do
          sample_text = 'A TDL with <<some_parameter> > that is nested'
          error_message = "Nested opening chevron '<'."
          expect { Engine.parse(sample_text) }.to raise_error(StandardError, error_message)
        end
      end
      
      context 'creation of source template' do
        it 'should accept an empty template text' do
          expect { Engine.new '' }.not_to raise_error
        end

        it 'should be created with a template text' do
          expect { Engine.new example_template }.not_to raise_error
        end

        it 'should know the source text' do
          expect(subject.source).to eq(example_template)
          instance = Engine.new ''
          expect(instance.source).to be_empty
        end

        it 'should indicate when a placeholder is empty or blank' do
          text = example_template.sub(/user_name/, '')
          msg = %q(An empty or blank parameter occurred in 'When  the username is "<>"'.)
          expect { Engine.new(text) }.to raise_error(Sequence::EmptyParameterError, msg)
        end

        it 'should indicate when a placeholder contains an invalid character' do
          text = example_template.sub(/user_name/, 'user%name')
          msg = "The invalid element '%' occurs in the parameter 'user%name'."
          expect { Engine.new(text)}.to raise_error(Sequence::InvalidElementError, msg)
        end
      end
      
      context 'rendering a template' do
        it 'should know the parameters it contains' do
          expect(subject.variables).to be == ['user_name', 'password']
          instance = Engine.new ''
          expect(instance.variables).to be_empty
        end
      end
      
      
    end
    
  end
end
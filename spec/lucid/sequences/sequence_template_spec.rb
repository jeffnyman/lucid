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

      let(:conditional_template) do
        example = <<-EXAMPLE
          When  the first name is "<first_name>"
          And   the last name is "<last_name>"
          <?age>
          And   the age is "<age>"
          </age>
          <?ssn>
          And   the ssn is "<ssn>"
          </ssn>
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

          expect(result.size).to eq(1)
          expect(result[0]).to eq([:static, sample_text])
        end

        it 'should parse a text line that consists of only a parameter' do
          sample_text = '<some_parameter>'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(1)
          expect(result[0]).to eq([:dynamic, strip_chevrons(sample_text)])
        end

        it 'should parse a text line with a parameter at the start' do
          sample_text = '<some_parameter> in a TDL statement'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(2)
          expect(result[0]).to eq([:dynamic, 'some_parameter'])
          expect(result[1]).to eq([:static,  ' in a TDL statement'])
        end

        it 'should parse a text line with a parameter at the end' do
          sample_text = 'a TDL statement with <some_parameter>'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(2)
          expect(result[0]).to eq([:static,  'a TDL statement with '])
          expect(result[1]).to eq([:dynamic, 'some_parameter'])
        end

        it 'should parse a text line with a parameter in the middle' do
          sample_text = 'a TDL statement with <some_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(3)
          expect(result[0]).to eq([:static,  'a TDL statement with '])
          expect(result[1]).to eq([:dynamic, 'some_parameter'])
          expect(result[2]).to eq([:static,  ' in it'])
        end

        it 'should parse a text line with two separated parameters' do
          sample_text = 'TDL with <one_parameter> and with <another_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(5)
          expect(result[0]).to eq([:static ,  'TDL with '])
          expect(result[1]).to eq([:dynamic, 'one_parameter'])
          expect(result[2]).to eq([:static , ' and with '])
          expect(result[3]).to eq([:dynamic, 'another_parameter'])
          expect(result[4]).to eq([:static,  ' in it'])
        end

        it 'should parse a text line with two consecutive parameters' do
          sample_text = 'TDL with <one_parameter> <another_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(5)
          expect(result[0]).to eq([:static,  'TDL with '])
          expect(result[1]).to eq([:dynamic, 'one_parameter'])
          expect(result[2]).to eq([:static,  ' '])
          expect(result[3]).to eq([:dynamic, 'another_parameter'])
          expect(result[4]).to eq([:static,  ' in it'])
        end

        it 'should parse a text line with escaped chevrons' do
          sample_text = 'A TDL \<parameter\> is escaped'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(1)
          expect(result[0]).to eq([:static, sample_text])
        end

        it 'should parse a text line with escaped chevrons in a parameter' do
          sample_text = 'A TDL with <some_\<\\>escaped\>_parameter> in it'
          result = Engine.parse(sample_text)

          expect(result.size).to eq(3)
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

        it 'should accept conditional sections' do
          expect { Engine.new(conditional_template) }.not_to raise_error
          instance = Engine.new(conditional_template)
          elements = instance.instance_variable_get(:@generated_source)
          sections = elements.select { |e| e.is_a?(Section) }
          names = sections.map { |e| e.to_s }
          expect(names).to eq(%w(<?age> <?ssn>))
        end

        it 'should indicate when a section has no closing tag' do
          text = conditional_template.sub(/<\/age>/, '')
          msg = 'Unterminated section <?age>.'
          expect { Engine.new(text) }.to raise_error(StandardError, msg)
        end

        it 'should indicate when a closing tag has no corresponding opening tag' do
          text = conditional_template.sub(/<\/age>/, '</test>')
          msg = "End of section </test> does not match current section 'age'."
          expect { Engine.new(text) }.to raise_error(StandardError, msg)
        end

        it 'should indicate when a closing tag is found without opening tag' do
          text = conditional_template.sub(/<\?ssn>/, '</test>')
          msg = "End of section </test> found while no corresponding section is open."
          expect { Engine.new(text) }.to raise_error(StandardError, msg)
        end
      end

      context 'rendering a template' do
        it 'should know the parameters it contains' do
          expect(subject.variables).to be == ['user_name', 'password']
          instance = Engine.new ''
          expect(instance.variables).to be_empty
        end

        it 'should generate the text with the actual values for parameters' do
          locals = { 'user_name' => 'jnyman' }
          generated_text = subject.output(Object.new, locals)
          expected = <<-RESULT
          Given the login page
          When  the username is "jnyman"
          And   the password is ""
          And   login is clicked
          RESULT

          expect(generated_text).to eq(expected)
        end

        it 'should generate the text with the actual non-string values for parameters' do
          locals = { 'user_name' => 'jnyman', 'password' => 12345 }
          generated_text = subject.output(Object.new, locals)

          expected = <<-RESULT
          Given the login page
          When  the username is "jnyman"
          And   the password is "12345"
          And   login is clicked
          RESULT

          expect(generated_text).to eq(expected)
        end

        it 'should generate the text with the actual values in context' do
          ContextObject = Struct.new(:user_name, :password)
          context = ContextObject.new('superb', 'tester')
          generated_text = subject.output(context, { 'user_name' => 'jnyman' })

          expected = <<-RESULT
          Given the login page
          When  the username is "jnyman"
          And   the password is "tester"
          And   login is clicked
          RESULT

          expect(generated_text).to eq(expected)
        end

        it 'should handle an empty source template' do
          instance = Engine.new('')
          expect(instance.output(nil, {})).to be_empty
        end

        it 'should generate conditional sections' do
          instance = Engine.new(conditional_template)
          locals = { 'first_name' => 'Jeff',
                     'last_name' => 'Nyman' ,
                     'age' => '41'
          }
          generated_text = instance.output(Object.new, locals)
          expected = <<-RESULT
          When  the first name is "Jeff"
          And   the last name is "Nyman"
          And   the age is "41"
          RESULT
          expect(generated_text).to eq(expected)

          locals['age'] = nil
          locals['ssn'] = '000-00-0000'
          generated_text = instance.output(Object.new, locals)

          expected = <<-RESULT
          When  the first name is "Jeff"
          And   the last name is "Nyman"
          And   the ssn is "000-00-0000"
          RESULT
          expect(generated_text).to eq(expected)
        end

        it 'should generate multi-valued actual text from parameters' do
          locals = { 'user_name' => %w(jnyman tester) }
          generated_text = subject.output(Object.new, locals)
          expected = <<-RESULT
          Given the login page
          When  the username is "jnyman<br/>tester"
          And   the password is ""
          And   login is clicked
          RESULT
          expect(generated_text).to eq(expected)
        end
      end

    end

  end
end

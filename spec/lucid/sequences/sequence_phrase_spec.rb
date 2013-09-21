require_relative '../../spec_helper'
require_relative '../../../lib/lucid/sequence/sequence_phrase'

module Sequence
  
  describe SequencePhrase do
    let(:example_phrase) { 'enter login credentials as <username>' }

    let(:example_template) do
      example = <<-EXAMPLE
        Given the login page
        When  the username is "<username>"
        And   the password is "<password>"
        And   login is clicked
      EXAMPLE
    end

    subject { SequencePhrase.new(example_phrase, example_template, true) }

    context 'sequence phrase generation' do
      it 'should be created with a phrase, steps and a data table indicator' do
        expect { SequencePhrase.new(example_phrase, example_template, true) }.not_to raise_error
      end

      it 'should indicate that a step argument can never be assigned a value via the phrase' do
        msg = "The step parameter 'password' does not appear in the phrase."
        expect { SequencePhrase.new(example_phrase, example_template, false) }.to raise_error(Sequence::UnreachableStepParameter, msg)
      end

      it 'should indicate when an argument in the phrase never occurs in any steps' do
        phrase = 'enter credentials as <tester>'
        msg = "The phrase parameter 'tester' does not appear in any step."
        expect { SequencePhrase.new(phrase, example_template, true) }.to raise_error(Sequence::UselessPhraseParameter, msg)
      end

      it 'should have a sequence key' do
        expect(subject.key).to eq('enter_login_credentials_as_X_T')
      end

      it 'should establish the placeholders from the sequence phrase' do
        expect(subject.phrase_params).to eq(%w[username])
      end

      it 'should know the placeholders from the phrase and generated template' do
        expect(subject.values).to eq(%w[username password])
      end
    end
    
    context 'sequence phrase execution' do

      let(:phrase_instance) { %Q|enter credentials as "jnyman"| }

      it 'should generate the steps' do
        text = subject.expand(phrase_instance, [ %w(password thx1138) ])
        expectation = <<-EXAMPLE
        Given the login page
        When  the username is "jnyman"
        And   the password is "thx1138"
        And   login is clicked
        EXAMPLE

        expect(text).to eq(expectation)
      end

      it 'should generate steps even when a step argument has no value' do
        text = subject.expand(phrase_instance, [ ])
        expectation = <<-EXAMPLE
        Given the login page
        When  the username is "jnyman"
        And   the password is ""
        And   login is clicked
        EXAMPLE

        expect(text).to eq(expectation)
      end

      it 'should unescape any double-quotes for phrase arguments' do
        specific_phrase = %q|enter credentials as "jnyman\""|
        text = subject.expand(specific_phrase, [ %w(password thx1138) ])
        expectation = <<-EXAMPLE
        Given the login page
        When  the username is "jnyman""
        And   the password is "thx1138"
        And   login is clicked
        EXAMPLE

        expect(text).to eq(expectation)
      end

      it 'should indicate when an unknown variable is used' do
        error_message = "Unknown sequence step parameter 'unknown'."
        args = [ %w(unknown anything) ]
        expect { subject.expand(phrase_instance, args) }.to raise_error(UnknownParameterError, error_message)
      end

      it 'should indicate when an argument gets a value from a phrase and a table' do
        phrase = %Q|enter credentials as "jnyman"|
        msg = "The sequence parameter 'username' has value 'jnyman' and 'tester'."
        args = [ %w(username tester), %w(password thx1138) ]
        expect { subject.expand(phrase, args) }.to raise_error(AmbiguousParameterValue, msg)
      end

      it 'should expand any built-in variables' do
        phrase = 'do nothing useful'
        quoted_steps = <<-EXAMPLE
        Given the following films:
        <quotes>
        Iron Man 3
        World War Z
        <quotes>
        EXAMPLE

        instance = SequencePhrase.new(phrase, quoted_steps, true)
        actual = instance.expand(phrase, [])
        expected = quoted_steps.gsub(/<quotes>/, '""')
        expect(actual).to eq(expected)
      end
    end
    
  end
  
end
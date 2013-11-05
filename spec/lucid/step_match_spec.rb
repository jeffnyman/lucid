require 'spec_helper'

require 'lucid/interface_rb/rb_language'
require 'lucid/interface_rb/rb_step_definition'

module Lucid
  describe StepMatch do

    WORD = '[[:word:]]'

    before do
      @rb_code = InterfaceRb::RbLanguage.new(nil)
    end

    def testdef(regexp)
      InterfaceRb::RbStepDefinition.new(@rb_code, regexp, lambda{}, {})
    end

    def step_match(regexp, name)
      testdef = testdef(regexp)
      StepMatch.new(testdef, name, nil, testdef.arguments_from(name))
    end

    it 'should format groups with format string' do
      result = step_match(/Lucid (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, 'Lucid parsed 10 tests this build')
      result.format_args('<span>%s</span>').should == 'Lucid <span>parsed</span> <span>10</span> <span>tests</span> this <span>build</span>'
    end

    it 'should format groups with format string when there are duplications' do
      result = step_match(/Lucid (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, 'Lucid testing 1 tester this test')
      result.format_args('<span>%s</span>').should == 'Lucid <span>testing</span> <span>1</span> <span>tester</span> this <span>test</span>'
    end

    it 'should format groups with block' do
      result = step_match(/Lucid (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, 'Lucid parsed 1 test this build')
      result.format_args(&lambda{|m| "<span>#{m}</span>"}).should == 'Lucid <span>parsed</span> <span>1</span> <span>test</span> this <span>build</span>'
    end

    it 'should format groups with proc object' do
      result = step_match(/Lucid (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, 'Lucid parsed 1 test this build')
      result.format_args(lambda{|m| "<span>#{m}</span>"}).should == 'Lucid <span>parsed</span> <span>1</span> <span>test</span> this <span>build</span>'
    end

    it 'should format groups even when the first group is optional and not matched' do
      result = step_match(/should( not)? show message '([^']*?)'$/, "App should show message 'Login failed.'")
      result.format_args('<span>%s</span>').should == "App should show message '<span>Login failed.</span>'"
    end

    it 'should format embedded groups' do
      result = step_match(/running( (\d+) scenarios)? (\d+) tests/, 'running 5 scenarios 10 tests')
      result.format_args('<span>%s</span>').should == 'running<span> 5 scenarios</span> <span>10</span> tests'
    end

  end
end
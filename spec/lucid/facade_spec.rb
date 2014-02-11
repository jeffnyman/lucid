require 'spec_helper'

module Lucid
  describe ContextLoader::Facade do

    let(:interface) {double('interface')}
    subject { ContextLoader::Orchestrator.new(interface,{}) }
    let(:facade) { ContextLoader::Facade.new(subject, interface) }

    it 'should produce AST::Table by #table' do
      facade.table( %{
      | study   | phase |
      | test-01 | I     |
      | test-02 | II    |
      } ).should be_kind_of(AST::Table)
    end

    it 'should produce AST::DocString by #doc_string with default content-type' do
      str = facade.doc_string('TEST')
      str.should be_kind_of(AST::DocString)
      str.content_type.should eq('')
    end

    it 'should produce AST::DocString by #doc_string with ruby content-type' do
      str = facade.doc_string('TEST','ruby')
      str.should be_kind_of(AST::DocString)
      str.content_type.should eq('ruby')
    end

  end
end

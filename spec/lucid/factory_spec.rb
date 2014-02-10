require_relative '../spec_helper'

module Lucid
  describe Factory do
    include Factory

    it 'should load a valid formatter' do
      generated_class = create_object_of('Lucid::Formatter::Html')
      generated_class.name.should == 'Lucid::Formatter::Html'
    end

    it 'should not load an invalid formatter' do
      expect { create_object_of('Lucid::Formatter::Testing') }.to raise_error(LoadError)
    end
  end
end

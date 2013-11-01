require 'spec_helper'
require 'lucid/interface_rb/rb_language'

module Lucid
  describe 'Pending' do
    before(:each) do
      l = InterfaceRb::RbLanguage.new(Runtime.new)
      l.begin_rb_scenario(double('scenario').as_null_object)
      @domain= l.current_domain
    end

    it 'should raise a Pending if no block is supplied' do
      lambda {
        @domain.pending 'TODO'
      }.should raise_error(Lucid::Pending, /TODO/)
    end

    it 'should raise a Pending if a supplied block fails as expected' do
      lambda {
        @domain.pending 'TODO' do
          raise 'that is a problem'
        end
      }.should raise_error(Lucid::Pending, /TODO/)
    end

    it 'should raise a Pending if a supplied block fails as expected with a double' do
      lambda {
        @domain.pending 'TODO' do
          m = double('test')
          m.should_receive(:testing)
          RSpec::Mocks.verify
        end
      }.should raise_error(Lucid::Pending, /TODO/)
    end

    it 'should raise a Pending if a supplied block starts working' do
      lambda {
        @domain.pending 'TODO' do
          # Nothing happens here.
        end
      }.should raise_error(Lucid::Pending, /TODO/)
    end
    
  end
end
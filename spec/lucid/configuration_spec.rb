require_relative '../spec_helper'

module Lucid
  module CLI
    describe Configuration do
      
      module ExposeOptions
        attr_reader :options
      end
      
      def config
        @config ||= Configuration.new(@out = StringIO.new, @error = StringIO.new).extend(ExposeOptions)
      end
      
      def with_these_files(*files)
        File.stub(:directory?).and_return(true)
        File.stub(:file?).and_return(true)
        Dir.stub(:[]).and_return(files)
      end
      
      def with_this_configuration_file(info)
        File.stub(:exist?).and_return(true)
        profile_file = info.is_a?(Hash) ? info.to_yaml : info
        IO.stub(:read).with('lucid.yml').and_return(profile_file)
      end
      
      it 'should require driver.rb files first' do
        with_these_files('/common/support/browser.rb', '/common/support/driver.rb')
        config.parse(%w{--require /common})
        
        config.library_context.should == %w(
            /common/support/driver.rb
            /common/support/browser.rb
        )
      end
      
      it 'should not require driver.rb files when a dry run is attempted' do
        with_these_files('/common/support/browser.rb', '/common/support/driver.rb')
        config.parse(%w{--require /common --dry-run})

        config.library_context.should == %w(
          /common/support/browser.rb
        )
      end
      
      it 'should require files in default definition locations' do
        with_these_files('/pages/page.rb', '/steps/steps.rb')
        config.parse(%w{--require /specs})
        
        config.definition_context.should == %w(
          /pages/page.rb
          /steps/steps.rb
        )
      end
      
      it 'should be able to exclude files based on a specific reference' do
        with_these_files('/common/support/browser.rb', '/common/support/driver.rb')
        config.parse(%w{--require /common --exclude browser.rb})
        
        config.spec_requires.should == %w(
          /common/support/driver.rb
        )
      end
      
      it 'should be able to exclude files based on a general pattern' do
        with_these_files('/steps/tester.rb', '/steps/tested.rb', '/steps/testing.rb', '/steps/quality.rb')
        config.parse(%w{--require /steps --exclude test(er|ed) --exclude quality})

        config.spec_requires.should == %w(
          /steps/testing.rb
        )
      end
      
      it 'should be able to use a --dry-run option' do
        config.parse(%w{--dry-run})
        config.options[:dry_run].should be_true
      end
      
      it 'should be able to use a --no-source option' do
        config.parse(%w{--no-source})
        config.options[:source].should be_false
      end
      
      it 'should be able to use a --no-matchers option' do
        config.parse(%w{--no-matchers})
        config.options[:matchers].should be_false
      end
      
      it 'should be able to use a --quiet option' do
        config.parse(%w{--quiet})
        config.options[:source].should be_false
        config.options[:matchers].should be_false
      end
      
      it 'should be able to use a --verbose option' do
        config.parse(%w{--verbose})
        config.options[:verbose].should be_true
      end

      it 'should be able to use an --out option' do
        config.parse(%w{--out report.txt})
        config.formats.should == [%w(standard report.txt)]
      end

      it 'should be able to use multiple --out options' do
        config.parse(%w{--format standard --out report1.txt --out report2.txt})
        config.formats.should == [%w(standard report2.txt)]
      end
      
    end
  end
end
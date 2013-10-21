require_relative '../spec_helper'

module Lucid
  describe Configuration do
    describe '.default' do
      subject { Configuration.default }

      it 'has an autoload_code_paths containing default Lucid folders' do
        subject.autoload_code_paths.should include('common')
        subject.autoload_code_paths.should include('steps')
        subject.autoload_code_paths.should include('pages')
      end
    end

    describe 'supports custom user options' do
      let(:user_options) { { :autoload_code_paths => ['library/common'] } }
      subject { Configuration.new(user_options) }

      it 'should allow the defaults to be overridden' do
        subject.autoload_code_paths.should == ['library/common']
      end
    end
  end
  
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

      it 'should default to a specs directory when no information is provided' do
        File.stub(:directory?).and_return(true)
        Dir.stub(:[]).with('specs/**/*.spec').and_return(['lucid.spec'])
        config.parse(%w{})
        config.spec_files.should == ['lucid.spec']
      end
      
      it 'should search for all specs in the specified directory' do
        File.stub(:directory?).and_return(true)
        Dir.stub(:[]).with('specs/**/*.spec').and_return(["lucid.spec"])
        config.parse(%w{specs/})
        config.spec_files.should == ['lucid.spec']
      end
      
      it 'should preserve the order of the spec files' do
        config.parse(%w{test_b.spec test_c.spec test_a.spec})
        config.spec_files.should == %w[test_b.spec test_c.spec test_a.spec]
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

      it 'should allow specifying environment variables on the command line' do
        config.parse(['test=this'])
        ENV['test'].should == 'this'
        config.spec_files.should_not include('test=this')
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
      
      describe 'generating output' do
      
        it 'should be able to use an --out option' do
          config.parse(%w{--out report.txt})
          config.formats.should == [%w(standard report.txt)]
        end
        
        it 'should be able to use multiple --out options' do
          config.parse(%w{--format standard --out report1.txt --out report2.txt})
          config.formats.should == [%w(standard report2.txt)]
        end
      
      end

      it 'should be able to use a --color option' do
        Lucid::Term::ANSIColor.should_receive(:coloring=).with(true)
        config.parse(['--color'])
      end

      it 'should accept --no-color option' do
        Lucid::Term::ANSIColor.should_receive(:coloring=).with(false)
        config = Configuration.new(StringIO.new)
        config.parse(['--no-color'])
      end
      
    end
  end
end
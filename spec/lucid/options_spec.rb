require_relative '../spec_helper'

module Lucid
  module CLI
    describe Options do

      before(:each) do
        Kernel.stub(:exit).and_return(nil)
      end
      
      def output_stream
        @output_stream ||= StringIO.new
      end

      def error_stream
        @error_stream ||= StringIO.new
      end
      
      def options
        @options ||= Options.new(output_stream, error_stream)
      end
      
      def prep_args(args)
        args.is_a?(Array) ? args : args.split(' ')
      end
      
      describe 'parsing options' do
        
        def during_parsing(command)
          yield
          options.parse(prep_args(command))
        end
        
        def after_parsing(command)
          options.parse(prep_args(command))
          yield
        end

        context '--version' do
          it "should display Lucid's version" do
            after_parsing('--version') do
              output_stream.string.should =~ /#{Lucid::VERSION}/
            end
          end

          it 'should exit from any Lucid execution' do
            during_parsing('--version') { Kernel.should_receive(:exit) }
          end
        end

        context 'environment variables' do
          it 'should put all environment variables into a hash' do
            after_parsing('MODE=symbiont AUTOSPEC=true') do
              options[:env_vars].should == {'MODE' => 'symbiont', 'AUTOSPEC' => 'true'}
            end
          end
        end
        
        context '-r or --require' do
          it 'should collect all specified files into an array' do
            after_parsing('--require file_a.rb -r file_b.rb') do
              options[:require].should == ['file_a.rb', 'file_b.rb']
            end
          end
        end

        context '-n NAME or --name NAME' do
          it 'should store provided scenario names as regular expressions' do
            after_parsing('-n sc1 --name sc2') { options[:name_regexps].should == [/sc1/,/sc2/] }
          end
        end

        context '-l LINES or --lines LINES' do
          it 'should add line numbers to spec files' do
            options.parse(%w{-l 42 FILE})
            options.instance_variable_get(:@args).should == ['FILE:42']
          end
        end

        context '-e PATTERN or --exclude PATTERN' do
          it 'should stored provided exclusions as regular expressions' do
            after_parsing('-e file1 --exclude file2') { options[:excludes].should == [/file1/,/file2/] }
          end
        end

        context '-b or --backtrace' do
          it 'should use a full backtrace during Lucid execution' do
            during_parsing("-b") do
              Lucid.should_receive(:use_full_backtrace=).with(true)
            end
          end
        end

        context '-t TAGS --tags TAGS' do
          it 'should store tags passed with different --tags options separately' do
            after_parsing('--tags @smoke --tags @wip') { options[:tag_expressions].should == ['@smoke', '@wip'] }
          end
          
          it 'should designate tags prefixed with ~ as tags to be excluded' do
            after_parsing('--tags ~@smoke,@wip') { options[:tag_expressions].should == ['~@smoke,@wip'] }
          end
        end

        context '-f FORMAT or --format FORMAT' do
          it 'should default to using the standard output stream (STDOUT) formatter' do
            after_parsing('-f standard') { options[:formats].should == [['standard', output_stream]] }
          end
        end

        context '-o [FILE|DIR] or --out [FILE|DIR]' do
          it 'should default to the standard formatter when not specified' do
            after_parsing('-o file.txt') { options[:formats].should == [['standard', 'file.txt']] }
          end

          it 'should set the output for the formatter defined for each option' do
            after_parsing('-f profile --out file.txt -f standard -o file2.txt') do
              options[:formats].should == [['profile', 'file.txt'], ['standard', 'file2.txt']]
            end
          end
        end
        
      end
      
    end
  end
end
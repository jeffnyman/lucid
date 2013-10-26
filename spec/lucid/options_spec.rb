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

      def with_this_configuration(info)
        Dir.stub(:glob).with('{,.config/,config/}lucid{.yml,.yaml}').and_return(['lucid.yml'])
        File.stub(:exist?).and_return(true)
        lucid_yml = info.is_a?(Hash) ? info.to_yaml : info
        IO.stub(:read).with('lucid.yml').and_return(lucid_yml)
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
          it 'should display Lucid version' do
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

        context '-p PROFILE or --profile PROFILE' do
          it 'respects --quiet when defined in the profile' do
            with_this_configuration('test' => '-q')

            options.parse(%w[-p test])
            options[:matchers].should be_false
            options[:source].should be_false
          end
          
          it 'uses the default profile passed in during initialization if none is specified by the user' do
            with_this_configuration({'default' => '--require test_helper'})

            options = Options.new(output_stream, error_stream, :default_profile => 'default')
            options.parse(%w{--format progress})
            options[:require].should include('test_helper')
          end

          it 'merges all unique values from both the command line and the profile' do
            with_this_configuration('test' => %w[--verbose])

            options.parse(%w[--wip --profile test])
            options[:wip].should be_true
            options[:verbose].should be_true
          end

          it 'gives precedence to the original options spec source path' do
            with_this_configuration('test' => %w[specs])

            options.parse(%w[test.spec -p test])
            options[:spec_source].should == %w[test.spec]
          end

          it 'combines the require files of both' do
            with_this_configuration('bar' => %w[--require specs -r helper.rb])

            options.parse(%w[--require test.rb -p bar])
            options[:require].should == %w[test.rb specs helper.rb]
          end

          it 'combines the tag names of both' do
            with_this_configuration('test' => %w[-t @smoke])

            options.parse(%w[--tags @wip -p test])
            options[:tag_expressions].should == ['@wip', '@smoke']
          end

          it 'only takes the paths from the original options, and disregards the profiles' do
            with_this_configuration('test' => %w[specs])

            options.parse(%w[test.spec -p test])
            options[:spec_source].should == ['test.spec']
          end

          it 'uses the paths from the profile when none are specified originally' do
            with_this_configuration('test' => %w[test.spec])

            options.parse(%w[-p test])
            options[:spec_source].should == ['test.spec']
          end

          it 'combines environment variables from the profile but gives precedence to command line args' do
            with_this_configuration('test' => %w[BROWSER=firefox DRIVER=mechanize])
            
            options.parse(%w[-p test DRIVER=watir CI=jenkins])
            options[:env_vars].should == {'CI' => 'jenkins', 'BROWSER' => 'firefox', 'DRIVER' => 'watir'}
          end

          it 'disregards STDOUT formatter defined in profile when another is passed in via command line' do
            with_this_configuration({'test' => %w[--format standard]})

            options.parse(%w{--format progress --profile test})
            options[:formats].should == [['progress', output_stream]]
          end

          it 'includes any non-STDOUT formatters from the profile' do
            with_this_configuration({'report' => %w[--format html -o results.html]})

            options.parse(%w{--format progress --profile report})
            options[:formats].should == [['progress', output_stream], ['html', 'results.html']]
          end

          it 'does not include STDOUT formatters from the profile if there is a STDOUT formatter in command line' do
            with_this_configuration({'report' => %w[--format html -o results.html --format standard]})

            options.parse(%w{--format progress --profile report})
            options[:formats].should == [['progress', output_stream], ['html', 'results.html']]
          end

          it 'includes any STDOUT formatters from the profile if no STDOUT formatter was specified in command line' do
            with_this_configuration({'report' => %w[--format html]})

            options.parse(%w{--format rerun -o rerun.txt --profile report})
            options[:formats].should == [['html', output_stream], ['rerun', 'rerun.txt']]
          end

          it 'assumes all of the formatters defined in the profile when none are specified on command line' do
            with_this_configuration({'report' => %w[--format progress --format html -o results.html]})

            options.parse(%w{--profile report})
            options[:formats].should == [['progress', output_stream], ['html', 'results.html']]
          end

          it 'only reads lucid.yml once' do
            original_parse_count = $lucid_yml_read_count
            $lucid_yml_read_count = 0
            
            begin
              with_this_configuration(<<-END
              <% $lucid_yml_read_count += 1 %>
              default: --format standard
              END
              )
              options = Options.new(output_stream, error_stream, :default_profile => 'default')
              options.parse(%w(-f progress))

              $lucid_yml_read_count.should == 1
            ensure
              $lucid_yml_read_count = original_parse_count
            end
          end
        end
        
        context '-P or --no-profile' do
          it 'disables profiles' do
            with_this_configuration({'default' => '-v --require file_specified_in_default_profile.rb'})

            after_parsing('-P --require test_helper.rb') do
              options[:require].should == ['test_helper.rb']
            end
          end

          it 'notifies the user that the profiles are being disabled' do
            with_this_configuration({'default' => '-v'})

            after_parsing('--no-profile --require test_helper.rb') do
              output_stream.string.should =~ /Disabling profiles.../
            end
          end
        end
        
        context '--matcher-type' do
          it 'parses the matcher type argument' do
            after_parsing('--matcher-type classic') do
              options[:matcher_type].should eql :classic
            end
          end
        end

        it 'assigns any extra arguments as paths to specs' do
          after_parsing('-f pretty test.spec other_specs') do
            options[:spec_source].should == ['test.spec', 'other_specs']
          end
        end

        it 'does not mistake environment variables as spec paths' do
          after_parsing('test.spec ENV=ci') do
            options[:spec_source].should == ['test.spec']
          end
        end
        
        describe 'dry-run' do
          it 'should have the default value for matchers' do
            with_this_configuration({'test' => %w[--dry-run]})
            options.parse(%w{--dry-run})
            options[:matchers].should == true
          end

          it 'should set matchers to false when no-matchers is provided after dry-run' do
            with_this_configuration({'test' => %w[--dry-run --no-snippets]})
            options.parse(%w{--dry-run --no-matchers})
            options[:matchers].should == false
          end

          it 'should set matchers to false when no-matchers is provided before dry-run' do
            with_this_configuration({'test' => %w[--no-snippet --dry-run]})
            options.parse(%w{--no-matchers --dry-run})
            options[:matchers].should == false
          end
        end
        
      end
      
    end
  end
end
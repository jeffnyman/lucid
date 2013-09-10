Given (/^a project with no spec repository$/) do
  in_lucent_directory do
    FileUtils.rm_rf 'specs' if File.directory?('specs')
  end
end

When (/^the command `([^`]*)` is executed$/) do |command|
  run_standard(unescape(command))
end

When (/^the following code is executed:$/) do |code|
  code = code.gsub("\n", ';')
  run_standard %{ruby -e "#{code}"}  
end

Then('the scenario should pass') do
  assert_exit_status 0
end

Given (/^a project with no spec repository$/) do
  in_lucent_directory do
    FileUtils.rm_rf 'specs' if File.directory?('specs')
  end
end

When (/^the command `([^`]*)` is executed$/) do |command|
  run_standard(command)
end
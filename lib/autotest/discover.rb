Autotest.add_discovery do
  if File.directory?('specs')
    if ENV['AUTOSPEC'] =~ /true/i
      'lucid'
    elsif ENV['AUTOSPEC'] =~ /false/i
      # noop
    else
      puts '(Not running specs. To run specs in autotest, set AUTOSPEC=true.)'
    end
  end
end

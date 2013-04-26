desc 'Generate the css for the html formatter from sass'
task :sass do
  sh 'sass -t expanded lib/lucid/formatter/cucumber.sass > lib/lucid/formatter/cucumber.css'
end
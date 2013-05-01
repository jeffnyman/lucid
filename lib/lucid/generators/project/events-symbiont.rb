AfterConfiguration do |config|
  puts("Specs are being executed from: #{config.spec_location}")
end

Before('~@practice') do
  @browser = Symbiont::Browser.start
end

AfterStep('@pause') do
  print "Press ENTER to continue..."
  STDIN.getc
end

After do |scenario|
  if scenario.failed?
    Dir::mkdir('results') if not File.directory?('results')
    screenshot = "./results/FAILED_#{scenario.name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png"

    # This way attempts to save the screenshot as a file.
    #@browser.driver.save_screenshot(screenshot)

    # This way the image is encoded into the results.
    encoded_img = @browser.driver.screenshot_as(:base64)
    embed("data:image/png;base64,#{encoded_img}", 'image/png')

    # This is an alternative way to embed.
    #embed screenshot, 'image/png'
  end
  Symbiont::Browser.stop
end

at_exit do
  Symbiont::Browser.stop
end

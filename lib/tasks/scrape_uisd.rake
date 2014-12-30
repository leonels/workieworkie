require 'rubygems'
require 'selenium-webdriver'

desc 'testing selenium'
task :sync => :environment do
  driver = Selenium::WebDriver.for :firefox
  driver.navigate.to 'http://www.applitrack.com/unitedisd/onlineapp/default.aspx?all=1'

  puts driver.title

  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until { driver.find_element(:id, 'AppliTrackListContent') }

  content = driver.find_element(:id, 'AppliTrackListContent')
  # puts content.text

  # content.find_elements(:class => 'title').each do |e|
  #   title = e.text
  #   puts title
  # end

  content.find_elements(:css => 'table').each do |table|
    title = table.find_element(:class => 'title')
    puts title.text

    # dept = table.find_element(:css => 'span.normal:nth-of-type(3)')
    dept = table.find_element(:css => 'tr:nth-child(8) td span.normal')
    puts "#{dept.text}"

    details = table.find_element(:css => 'div.AppliTrackJobPostingAttachments ul li a')
    puts details.attribute('href')
    puts '---------------------------'
  end  

  driver.quit

  # js_code = "return document.getElementsByTagName('div')"
  # elements = browser.execute_script(js_code)
  # elements.each{|e| puts e.text }
end
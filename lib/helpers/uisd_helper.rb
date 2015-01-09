module UisdHelper

require 'rubygems'
require 'selenium-webdriver'

  def load_uisd_jobs
    driver = Selenium::WebDriver.for :firefox
    driver.navigate.to 'http://www.applitrack.com/unitedisd/onlineapp/default.aspx?all=1'

    puts "***********************"
    puts "*** #{driver.title} ***"
    puts "***********************"

    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { driver.find_element(:id, 'AppliTrackListContent') }

    content = driver.find_element(:id, 'AppliTrackListContent')
    # puts content.text

    # content.find_elements(:class => 'title').each do |e|
    #   title = e.text
    #   puts title
    # end

    jobs = []

    content.find_elements(:css => 'table').each do |table|
      title = table.find_element(:class => 'title')
      # puts title.text

      # dept = table.find_element(:css => 'span.normal:nth-of-type(3)')
      dept = table.find_element(:css => 'tr:nth-child(8) td span.normal')
      # puts "#{dept.text}"

      details = table.find_element(:css => 'div.AppliTrackJobPostingAttachments ul li a')
      link =  details.attribute('href')
      # puts link
      # puts '---------------------------'

      jobs << {
        'title' => title.text,
        'department' => dept.text,
        'link' => link
      }
    end  

    driver.quit

    # js_code = "return document.getElementsByTagName('div')"
    # elements = browser.execute_script(js_code)
    # elements.each{|e| puts e.text }
    jobs
  end

  # jobs param is supposed to be an array of links
  def update_jobs_uisd(jobs, only_these)
    only_these.each do |o|
      # 'DETECT' RETURNS THE HASH ELEMENT ITSELF
      j = jobs.detect {|h| h['link'] == o}
      job = Job.where(link: o)
      job[0].title = j['title']
      # job[0].salary = j['salary']
      job[0].department = j['department']
      job[0].city = 'Laredo'
      job[0].origin = 'United ISD'
      job[0].link = j['link']
      job[0].save
    end
    puts "Total of #{jobs.size} updated successfully."
  end

  # jobs param is supposed to be an array of 
  # job hashes 
  def save_jobs_uisd(jobs, only_these=nil)
    if only_these.nil?
      jobs.each do |j|
        job = Job.new
        job.title = j['title']
        # job.salary = j['salary']
        job.department = j['department']
        job.city = 'Laredo'
        job.origin = 'United ISD'
        job.link = j['link']
        job.save
      end
      puts "Total of #{jobs.size} saved successfully."
    else
      only_these.each do |o|
        # 'ANY' RETURNS A BOOLEAN
        # what = jobs.any? {|h| h['link'] == o}
        
        # 'DETECT' RETURNS THE HASH ELEMENT ITSELF
        j = jobs.detect {|h| h['link'] == o}
        job = Job.new
        job.title = j['title']
        # job.salary = j['salary']
        job.department = j['department']
        job.city = 'Laredo'
        job.origin = 'United ISD'
        job.link = j['link']
        job.save
      end
      puts "Total of #{only_these.size} saved successfully."
    end
    #
    #  add a VERBOSE flag, to output total or not
    #
  end

end
require "#{Rails.root}/lib/helpers/uisd_helper"
require 'selenium-webdriver'
require 'headless'

include UisdHelper

def setup
  @headless = Headless.new
  @headless.start
  @driver = Selenium::WebDriver.for :firefox
end

def teardown
  @driver.quit
  @headless.destroy
end

namespace :scrape_uisd do

  setup

  desc 'sync UISD'
  task :sync => :environment do
    jobs_uisd = load_uisd_jobs
    puts jobs_uisd

    jobs_workie = Job.where("origin = ?", 'United ISD')

    ids_uisd = jobs_uisd.map{|j| j['link']}
    ids_workie = jobs_workie.map{|j| j['link']}

    puts '-----------------------------'
    puts "There are #{ids_uisd.size} job(s) on the United ISD website."
    puts '-----------------------------'

    puts "There are #{ids_workie.size} job(s) on Wurkies from United ISD website."
    puts '-----------------------------'

    ###
    ### =>  DELETE DUPLICATES
    ###
    duplicates = find_duplicates(ids_workie)
    # remove from the array too
    ids_workie = ids_workie - duplicates
    delete_duplicate_jobs(duplicates)
    puts '-----------------------------'  

    # finds the ones in common, 
    # these are the ones we want to update
    ### 
    ### =>  UPDATE EXISTING JOBS
    ### 
    intersect = ids_uisd & ids_workie
    update_jobs_uisd(jobs_uisd, intersect)

    # substract the ones in common,
    # these are the ones that are not on United ISD Website
    jobs_outdated = ids_workie - intersect 
    puts '-----------------------------'

    ###
    ### =>  REMOVE OUTDATED
    ###
    delete_jobs(jobs_outdated)
    puts '-----------------------------'

    jobs_to_check_for_update = intersect
    puts '-----------------------------'

    jobs_to_add = ids_uisd - jobs_to_check_for_update

    ### 
    ### =>  ADD NEW JOBS
    ### 
    puts "#{jobs_to_add.size} jobs will be added."
    Rake::Task['scrape_uisd:import'].invoke(jobs_to_add) unless jobs_to_add.empty?
    puts '-----------------------------'

    teardown
  end

  desc 'Import United ISD jobs to database'
  task :import, [:job_ids] => :environment do |t, args|
    puts "Importing jobs into database..."
    # import only the jobs specified 
    if args[:job_ids].kind_of?(Array)
      jobs = load_uisd_jobs
      save_jobs_uisd(jobs, args[:job_ids])
      puts "#{args[:job_ids].size} jobs where added."
    # import all jobs from webb county website
    else
      jobs = load_uisd_jobs
      puts jobs
      save_jobs_uisd jobs
      puts "#{jobs.size} jobs where added."
    end
  end # task  

end
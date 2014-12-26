require "#{Rails.root}/lib/helpers/city_of_laredo_helper"
require "#{Rails.root}/lib/helpers/tasks_helper"

include CityOfLaredoHelper
include TasksHelper

namespace :scrape_city_of_laredo do

  desc 'sync City of Laredo'
  task :sync => :environment do
    jobs_city = load_city_jobs
    jobs_workie = Job.where("origin =?", 'City of Laredo')

    ids_city = jobs_city.map{|j| j['link']}
    ids_workie = jobs_workie.map{|j| j['link']}

    puts '-----------------------------'
    puts "There are #{ids_city.size} job(s) on the City of Laredo website."
    puts '-----------------------------'

    puts "There are #{ids_workie.size} job(s) on Wurkies from City of Laredo website."
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
    intersect = ids_city & ids_workie
    update_jobs_city(jobs_city, intersect)

    # substract the ones in common,
    # these are the ones that are not on Webb County Website
    jobs_outdated = ids_workie - intersect 
    puts '-----------------------------'

    ###
    ### =>  REMOVE OUTDATED
    ###
    delete_jobs(jobs_outdated)
    puts '-----------------------------'

    jobs_to_check_for_update = intersect
    puts '-----------------------------'

    jobs_to_add = ids_city - jobs_to_check_for_update

    ### 
    ### =>  ADD NEW JOBS
    ### 
    puts "#{jobs_to_add.size} jobs will be added."
    Rake::Task['scrape_city_of_laredo:import'].invoke(jobs_to_add) unless jobs_to_add.empty?
    puts '-----------------------------'

  end

  desc 'Import City of Laredo jobs to database'
  task :import, [:job_ids] => :environment do |t, args|
    puts "Importing jobs into database..."
    # import only the jobs specified 
    if args[:job_ids].kind_of?(Array)
      jobs = load_city_jobs
      save_jobs_city(jobs, args[:job_ids])
      puts "#{args[:job_ids].size} jobs where added."
    # import all jobs from webb county website
    else
      jobs = load_city_jobs
      puts jobs
      save_jobs_city jobs
      puts "#{jobs.size} jobs where added."
    end
  end # task

  # desc 'Scrape City of Laredo jobs'
  # task :run => :environment do

  #   agent = Mechanize.new
  #   url = "http://agency.governmentjobs.com/laredo/default.cfm"
  #   agent.get(url)

  #   puts ""
  #   puts ""
  #   puts "********************************************"
  #   puts "***** SCRAPING Jobs at City of Laredo *****"
  #   puts "** #{url} **"

  #   jobs = parse_city_of_laredo agent, url

  #   puts "** There is a total of #{jobs.count} job(s) **"
  #   puts "********************************************"
  #   puts ""
  #   puts ""

  #   output_to_terminal jobs

  # end # task run

  # desc 'Import City of Laredo jobs to database'
  # task :import => :environment do
  #   puts "Importing jobs into database..."

  #   agent = Mechanize.new
  #   url = "http://agency.governmentjobs.com/laredo/default.cfm"
  #   agent.get(url)

  #   jobs = parse_city_of_laredo agent, url

  #   jobs.each do |j|
  #     job = Job.new
  #     job.title = j['title']
  #     job.salary = j['salary']
  #     job.department = j['department']
  #     job.origin = 'City of Laredo'
  #     job.link = j['link']
  #     job.save
  #   end

  #   puts "Total of #{jobs.count} imported successfully."

  # end # task import

end # namespace
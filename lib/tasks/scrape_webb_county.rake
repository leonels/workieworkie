require "#{Rails.root}/lib/helpers/webb_county_helper"
require "#{Rails.root}/lib/helpers/tasks_helper"

include WebbCountyHelper
include TasksHelper

namespace :scrape_webb_county do 

  desc 'sync'
  task :sync => :environment do
    
    jobs_webb_county = load_jobs
    jobs_workie = Job.where("origin = ?", 'Webb County')

    ids_webb_county = jobs_webb_county.map{|j| j['link']} 
    ids_workie = jobs_workie.map{|j| j['link']} 

    puts '-----------------------------'
    puts "There are #{ids_webb_county.size} job(s) on the Webb County website."
    puts '-----------------------------'

    puts "There are #{ids_workie.size} job(s) on WorkieWorkie from Webb County website."
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
    intersect = ids_webb_county & ids_workie
    update_jobs_webb(jobs_webb_county, intersect)

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

    jobs_to_add = ids_webb_county - jobs_to_check_for_update
    
    ### 
    ### =>  ADD NEW JOBS
    ### 
    puts "#{jobs_to_add.size} jobs will be added."
    Rake::Task['scrape_webb_county:import'].invoke(jobs_to_add) unless jobs_to_add.empty?
    puts '-----------------------------'

  end

  desc 'Import Webb County jobs to database'
  task :import, [:job_ids] => :environment do |t, args|
    puts "Importing jobs into database..."
    # import only the jobs specified 
    if args[:job_ids].kind_of?(Array)
      jobs = load_jobs
      save_jobs(jobs, args[:job_ids])
      puts "#{args[:job_ids].size} jobs where added."
    # import all jobs from webb county website
    else
      jobs = load_jobs
      puts jobs
      save_jobs jobs
      puts "#{jobs.size} jobs where added."
    end
  end # task

end # namespace 
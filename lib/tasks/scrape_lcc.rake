require "#{Rails.root}/lib/helpers/lcc_helper"
require "#{Rails.root}/lib/helpers/tasks_helper"

include LccHelper
include TasksHelper

require 'open-uri'

namespace :scrape_lcc do

  desc 'sync LCC'
  task :sync => :environment do

    jobs_lcc = load_lcc_jobs
    jobs_workie = Job.where("origin = ?", 'Laredo Community College')

    ids_lcc = jobs_lcc.map{|j| j['link']}
    ids_workie = jobs_workie.map{|j| j['link']}

    puts '-----------------------------'
    puts "There are #{ids_lcc.size} job(s) on the LCC website."
    puts '-----------------------------'

    puts "There are #{ids_workie.size} job(s) on Wurkies from LCC website."
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
    intersect = ids_lcc & ids_workie
    update_jobs_lcc(jobs_lcc, intersect)

    # substract the ones in common,
    # these are the ones that are not on LCC Website
    jobs_outdated = ids_workie - intersect 
    puts '-----------------------------'

    ###
    ### =>  REMOVE OUTDATED
    ###
    delete_jobs(jobs_outdated)
    puts '-----------------------------'

    jobs_to_check_for_update = intersect
    puts '-----------------------------'

    jobs_to_add = ids_lcc - jobs_to_check_for_update

    ### 
    ### =>  ADD NEW JOBS
    ### 
    puts "#{jobs_to_add.size} jobs will be added."
    Rake::Task['scrape_lcc:import'].invoke(jobs_to_add) unless jobs_to_add.empty?
    puts '-----------------------------'

  end

  desc 'Import Laredo Community College jobs to database'
  task :import, [:job_ids] => :environment do |t, args|
    puts "Importing jobs into database..."
    # import only the jobs specified 
    if args[:job_ids].kind_of?(Array)
      jobs = load_lcc_jobs
      save_jobs_lcc(jobs, args[:job_ids])
      puts "#{args[:job_ids].size} jobs where added."
    # import all jobs from webb county website
    else
      jobs = load_lcc_jobs
      puts jobs
      save_jobs_lcc jobs
      puts "#{jobs.size} jobs where added."
    end
  end # task

end # namespace
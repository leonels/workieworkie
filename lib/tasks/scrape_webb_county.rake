require "#{Rails.root}/lib/helpers/webb_county_helper"
include WebbCountyHelper

namespace :scrape_webb_county do 

  #####################
  # DELETE
  # UPDATE
  # ADD
  #####################

  desc 'load'
  task :load => :environment do 
    @jobs = load_jobs
  end

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
    puts "#{duplicates.size} jobs will be deleted because they are duplicates."
    delete_duplicate_jobs(duplicates)
    puts '-----------------------------'
    
    # finds the ones in common, 
    # these are the ones we want to update
    intersect = ids_webb_county & ids_workie
     #update_jobs(intersect)
     # jobs = load_jobs(intersect)

    # substract the ones in common,
    # these are the ones that are not on Webb County Website
    jobs_outdated = ids_workie - intersect 
    puts "#{jobs_outdated.size} job(s) will be deleted because they are no longer on Webb County website."
    puts '-----------------------------'
    
    ###
    ### =>  OUTDATED
    ###
    delete_jobs(jobs_outdated)

    jobs_to_check_for_update = intersect
    puts "#{jobs_to_check_for_update.size} job(s) will be kept and checked for updates."
    puts '-----------------------------'

    jobs_to_add = ids_webb_county - jobs_to_check_for_update
    
    puts "#{jobs_to_add.size} jobs will be added."
    Rake::Task['scrape_webb_county:import'].invoke(jobs_to_add) unless jobs_to_add.empty?
    # save_jobs(jobs_to_add)
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

  # I BELIEVE THIS WHOLE TASK BELOW MUST BE DELETED
  # FUNCTIONALITY IS ON sync TASK NOW
  desc "Import only jobs not on database; update existing jobs currently online; delete jobs not online anymore"
  task :update => :environment do
    current_jobs = Job.where("origin = ?", 'Webb County')
    puts "There is a total of #{current_jobs.count} Webb County jobs"
    jobs_array = []
    current_jobs.each do |job|
      jobs_array << {
            'title' => job.title, 
            'salary' => job.salary, 
            'department' => job.department,
            'origin' => job.origin,
            'link' => job.link
          }
    end

    source_jobs = load_jobs

    # if there are more jobs on source, than on workieworkie
    # that means we need to go and grab the new ones 
    if source_jobs.size > jobs_array.size
      puts 'online has more, so need to go grab some'
      ids_source = source_jobs.map{|j| j['link']}
      ids_target = jobs_array.map{|j| j['link']}

      # find jobs that are on webb county website but not on workie workie
      job_ids = []
      job_ids = ids_source - ids_target
      puts "#{job_ids.size} job(s) to add"      
    else
      puts 'our website has more'
    end

    if job_ids.nil?

    else
      # need to add new jobs, they are in the 'a' array 
      # 'a' is an array of links 
      puts job_ids
      Rake::Task['scrape_webb_county:import'].invoke(job_ids) unless job_ids.nil?
    end

  end

end # namespace 
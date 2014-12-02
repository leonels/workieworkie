require "#{Rails.root}/lib/helpers/webb_county_helper"
include WebbCountyHelper

namespace :scrape_webb_county do 

  desc 'test'
  task :run => :environment do 
    jobs = load_jobs
    puts jobs
  end

  desc 'Import Webb County jobs to database'
  task :import, [:job_ids] => :environment do |t, args|
    puts "Importing jobs into database..."

    # PSEUDOCODE
    # update jobs already on workieworkie
    # delete jobs not longer on source
    # add new jobs

    # if call comes from the update task and provides jobs as argument
    if args[:job_ids].kind_of?(Array)

      parsed_jobs = load_jobs

      jobs = []

      # args[:job_ids] contains a list of links
      args[:job_ids].each do |id|
        # parsed_jobs.reject { |j| unless j['link'] == id }
        # parsed_jobs.each do |j|
        #   if j['link'] == id
        #     jobs << {
        #       'title' => j['title'],
        #       'salary' => j['salary'],
        #       'department' => j['department'],
        #       'link' => j['link'],
        #       'origin' => 'Webb County'
        #     }
        #   end
        # end
      end

      save_jobs jobs

    # if it's just an import, not an update
    else

      jobs = load_jobs
      save_jobs jobs

    end
  end # task

  desc 'Delete jobs'
  # task :delete, [:jobs_to_delete] => :environment do |t, args|
  task :delete => :environment do
    puts 'Deleting jobs from database'

    jobs = load_jobs

  end

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
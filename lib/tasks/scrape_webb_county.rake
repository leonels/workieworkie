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

  desc 'delete'
  task :delete => :environment do
    jobs_original = load_jobs
    jobs_site = Job.where("origin = ?", 'Webb County')

    ids_original = jobs_original.map{|j| j['link']} 
    ids_site = jobs_site.map{|j| j['link']} 

    puts '-----------------------------'
    puts "There are #{ids_original.size} job(s) on the Webb County website."
    puts "There are #{ids_site.size} job(s) on WorkieWorkie."
    puts '-----------------------------'
    intersect = ids_original & ids_site
    puts "#{intersect.size} jobs will be kept."
    deleted = ids_site.size - intersect.size
    puts "#{deleted} jobs will be deleted."
    puts '-----------------------------'

    # ids_original.each do |id|
    #   should_i_delete = false
    #   # ids_site.map { |j| puts j }
    #   ids_site.each do |i|

    #   end
    #   le_array = ids_site.reject { |j| j != id }
    #   puts le_array.size
    # end
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
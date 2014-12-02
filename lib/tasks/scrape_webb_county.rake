namespace :scrape_webb_county do 

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

def load_jobs
  agent = Mechanize.new
  url = "http://agency.governmentjobs.com/webbcounty/default.cfm"
  agent.get(url)

  puts ""
  puts ""
  puts "********************************************"
  puts "***** SCRAPING Jobs at Webb County *****"
  puts "** #{url} **"

  jobs = parse_webb_county agent, url

  puts "** There is a total of #{jobs.count} job(s) **"
  puts "********************************************"
  puts ""
  puts ""

  # add a --verbose flag to output jobs to terminal
  # output_to_terminal jobs
  
  jobs
end

def output_to_terminal jobs
  jobs.each do |job|
    puts "TITLE: #{job['title']}"
    puts "SALARY: #{job['salary']}"
    puts "LINK: #{job['link']}"
    puts "DEPARTMENT: #{job['department']}"
    puts "----------------------------------"
  end
end

def parse_webb_county agent, base_url
  recordset =  agent.page.search('td.recordset').text.strip.squish
  recordset = recordset.split(' ')

  page = recordset.last.to_i
  jobs = []
  current_page = 1

  # CAREFUL: it can fail because the first tr is the heading, so 
  # it doesn't have a link to be parsed
  # so you get undefined method for nil:NilClass
  # the line unless title.empty? should take care of that

  page.times do

    table = agent.page.search('table.NEOGOV_joblist')
    table.search('tr').each do |tr|
      title_anchor_tag = tr.search('.jobtitle a')
      
      unless title_anchor_tag.empty?
        salary = tr.search('td:nth-child(3)').text.strip
        
        # extract the href value from the anchor tag
        link_path = agent.page.link_with(:text => title_anchor_tag.text).href
        
        # reconstruct the link
        link_complete = "http://agency.governmentjobs.com/#{link_path}"

        # parse link and get only the query (same as link_path, but removing the file name)
        link_parsed = URI.parse(link_complete)
        link_query = link_parsed.query
        
        # divide up the url parameters 
        if link_query
          link_split = link_query.split('&')
        end

        title_text = remove_comma_and_everything_after(title_anchor_tag.text.strip)
        
        if link_split
          link_reloaded = "#{base_url}?#{link_split[0]}&#{link_split[1]}"
        end

        jobs << {
            'title' => title_text, 
            'salary' => salary, 
            'link' => link_reloaded
          }
      end
    end

    current_page += 1
    form = agent.page.forms.third
    form.pageNumber = current_page
    form.submit
    
  end # recordset.times 

  jobs.each do |job|
    department = get_job(job['title'])
    job['department'] = department
  end
end # parse_webb_county

def clean_string string
  string.gsub!(/\r?\t?\n?/, '')
  string.gsub('Department:', '')
end

def get_job(title)
  title_split = title.split('-')
  title_split.last
end

def save_jobs(jobs)
  jobs.each do |j|
    job = Job.new
    job.title = j['title']
    job.salary = j['salary']
    job.department = j['department']
    job.origin = 'Webb County'
    job.link = j['link']
    job.save
  end
  #
  #  add a VERBOSE flag, to output total or not
  #
  puts "Total of #{jobs.size} saved successfully."
end

def remove_comma_and_everything_after(text)
  # remove the comma and everything after it 
  # Bridge Officer Collector, (B154061-2), R...
  if text.respond_to?('split')
    title_split = text.split(',')
    return title_split[0]
  else
    return text
  end
end
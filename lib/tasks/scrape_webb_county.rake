namespace :scrape_webb_county do 

  desc 'Scrape Webb County jobs'
  task :run => :environment do

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

    output_to_terminal jobs

  end # task

  desc 'Import Webb County jobs to database'
  task :import => :environment do
    puts "Importing jobs into database..."

    agent = Mechanize.new
    url = "http://agency.governmentjobs.com/webbcounty/default.cfm"
    agent.get(url)

    jobs = parse_webb_county agent, url

    jobs.each do |j|
      job = Job.new
      job.title = j['title']
      job.salary = j['salary']
      job.department = j['department']
      job.origin = 'Webb County'
      job.link = j['link']
      job.save
    end

    puts "Total of #{jobs.count} imported successfully."
  end # task

end # namespace 

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
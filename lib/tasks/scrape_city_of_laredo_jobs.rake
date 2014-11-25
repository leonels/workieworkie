desc 'Scraping City of Laredo jobs'

task :scrape_city_of_laredo_jobs => :environment do
  agent = Mechanize.new
  url = "http://agency.governmentjobs.com/laredo/default.cfm"
  agent.get(url)

  puts ""
  puts ""
  puts "********************************************"
  puts "***** SCRAPING Jobs at City of Laredo *****"
  puts "** #{url} **"

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
    table.search('tr').each do |j|
      title = j.search('.jobtitle a')
      
      unless title.empty?
        salary = j.search('.jobtitle[style="white-space: nowrap;"]').text.strip
        
        link_path = agent.page.link_with(:text => title.text).href
        link_complete = "http://agency.governmentjobs.com/#{link_path}"
        link_parsed = URI.parse(link_complete)
        link_query = link_parsed.query
        
        if link_query
          link_split = link_query.split('&')
        end
        
        title_text = title.text.strip
        if title_text.respond_to?('split')
          title_split = title_text.split(',')
        end
        if link_split
          link_reloaded = "#{url}?#{link_split[0]}&#{link_split[1]}"
        end
        jobs << {
            'title' => title_split[0], 
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

  puts "** There is a total of #{jobs.count} job(s) **"
  puts "********************************************"
  puts ""
  puts ""

  jobs.each do |j|
    puts "TITLE: #{j['title']}"
    puts "SALARY: #{j['salary']}"
    puts "LINK: #{j['link']}"
    puts "----------------------------------"
  end

end

module LccHelper

  def load_lcc_jobs
    agent = Mechanize.new
    url = "http://www.laredo.edu/HumanRes/wraper.php"
    agent.get(url)

    doc = Nokogiri::HTML(open(url).read)
    table_selector = 'table.tablesorter tbody'
    jobs = parse_lcc table_selector, doc

    table_selector = 'table.tablesorter1 tbody'
    jobs_to_append = parse_lcc table_selector, doc
    jobs << jobs_to_append[0]

    table_selector = 'table.tablesorter2 tbody'
    jobs_to_append = parse_lcc table_selector, doc
    jobs << jobs_to_append[0]
    
    jobs
  end

  def parse_lcc table_selector, doc
    puts "Parsing table in progress..."
    table = doc.css(table_selector)

    jobs = []
    c = 1
    number = (table.css('a')).count
    number.times do 
      title = table.css("td:nth-child(#{c})").text.strip
      salary = table.css("td:nth-child(#{c+1})").text.strip
      department =  table.css("td:nth-child(#{c+2})").text.strip
      link = (table.css("td:nth-child(#{c})")).at_css('a')[:href]
      link = "http://www.laredo.edu/HumanRes/#{link}"

      c += 5
      jobs << {
        'title' => title, 
        'salary' => salary, 
        'department' => department,
        'link' => link
      }
    end
    return jobs
  end

	def output_lcc jobs
	  jobs.each do |job|
	    puts "TITLE: #{job['title']}"
	    puts "SALARY: #{job['salary']}"
	    puts "DEPARTMENT: #{job['department']}"
	    puts "LINK: #{job['link']}"
	    puts "----------------------------------"
	  end
	end

  # jobs param is supposed to be an array of links
  def update_jobs_lcc(jobs, only_these)
    only_these.each do |o|
      # 'DETECT' RETURNS THE HASH ELEMENT ITSELF
      j = jobs.detect {|h| h['link'] == o}
      job = Job.where(link: o)
      job[0].title = j['title']
      job[0].salary = j['salary']
      job[0].department = j['department']
      job[0].city = 'Laredo'
      job[0].origin = 'Laredo Community College'
      job[0].link = j['link']
      job[0].save
    end
    puts "Total of #{jobs.size} updated successfully."
  end

  # jobs param is supposed to be an array of 
  # job hashes 
  def save_jobs_lcc(jobs, only_these=nil)
    if only_these.nil?
      jobs.each do |j|
        job = Job.new
        job.title = j['title']
        job.salary = j['salary']
        job.department = j['department']
        job.city = 'Laredo'
        job.origin = 'Laredo Community College'
        job.link = j['link']
        job.save
      end
      puts "Total of #{jobs.size} saved successfully."
    else
      only_these.each do |o|
        # 'ANY' RETURNS A BOOLEAN
        # what = jobs.any? {|h| h['link'] == o}
        
        # 'DETECT' RETURNS THE HASH ELEMENT ITSELF
        j = jobs.detect {|h| h['link'] == o}
        job = Job.new
        job.title = j['title']
        job.salary = j['salary']
        job.department = j['department']
        job.city = 'Laredo'
        job.origin = 'Laredo Community College'
        job.link = j['link']
        job.save
      end
      puts "Total of #{only_these.size} saved successfully."
    end
    #
    #  add a VERBOSE flag, to output total or not
    #
  end

end
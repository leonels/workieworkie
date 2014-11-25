require 'open-uri'

namespace :scrape_lcc do
  desc 'Scrape LCC jobs and output results to terminal'
  task :run => :environment do

    url = "http://www.laredo.edu/HumanRes/wraper.php"
    puts "*****************************************************"
    puts "***** SCRAPING Jobs at Laredo Community College *****"
    puts "Scraping #{url}..."

    agent = Mechanize.new
    
    agent.get(url)

    doc = Nokogiri::HTML(open(url).read)

    jobs = parse_lcc 'table.tablesorter tbody', doc
    output_lcc jobs
    jobs = parse_lcc 'table.tablesorter1 tbody', doc
    output_lcc jobs
    jobs = parse_lcc 'table.tablesorter2 tbody', doc
    output_lcc jobs

    puts "Scrape finished successfully."

  end # task

  desc 'Import LCC jobs to database'
  task :import => :environment do
    url = "http://www.laredo.edu/HumanRes/wraper.php"
    puts "*****************************************************"
    puts "***** SCRAPING Jobs at Laredo Community College *****"
    puts "Scraping #{url}..."

    agent = Mechanize.new
    
    agent.get(url)

    doc = Nokogiri::HTML(open(url).read)

    puts "Importing jobs into database..."
    jobs = parse_lcc 'table.tablesorter tbody', doc
    jobs.each do |j|
      job = Job.new
      job.title = j['title']
      job.salary = j['salary']
      job.department = j['department']
      job.origin = 'Laredo Community College'
      job.link = j['link']
      job.save
    end
    
    jobs = parse_lcc 'table.tablesorter1 tbody', doc
    jobs.each do |j|
      job = Job.new
      job.title = j['title']
      job.salary = j['salary']
      job.department = j['department']
      job.origin = 'Laredo Community College'
      job.link = j['link']
      job.save
    end
    
    jobs = parse_lcc 'table.tablesorter2 tbody', doc
    jobs.each do |j|
      job = Job.new
      job.title = j['title']
      job.salary = j['salary']
      job.department = j['department']
      job.origin = 'Laredo Community College'
      job.link = j['link']
      job.save
    end

    puts "Import finished successfully."
  end

end # namespace

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
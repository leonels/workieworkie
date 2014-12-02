namespace :scrape_city_of_laredo do
  desc 'Scrape City of Laredo jobs'
  task :run => :environment do

    agent = Mechanize.new
    url = "http://agency.governmentjobs.com/laredo/default.cfm"
    agent.get(url)

    puts ""
    puts ""
    puts "********************************************"
    puts "***** SCRAPING Jobs at City of Laredo *****"
    puts "** #{url} **"

    jobs = parse_city_of_laredo agent, url

    puts "** There is a total of #{jobs.count} job(s) **"
    puts "********************************************"
    puts ""
    puts ""

    output_to_terminal jobs

  end # task run

  desc 'Import City of Laredo jobs to database'
  task :import => :environment do
    puts "Importing jobs into database..."

    agent = Mechanize.new
    url = "http://agency.governmentjobs.com/laredo/default.cfm"
    agent.get(url)

    jobs = parse_city_of_laredo agent, url

    jobs.each do |j|
      job = Job.new
      job.title = j['title']
      job.salary = j['salary']
      job.department = j['department']
      job.origin = 'City of Laredo'
      job.link = j['link']
      job.save
    end

    puts "Total of #{jobs.count} imported successfully."

  end # task import

end # namespace
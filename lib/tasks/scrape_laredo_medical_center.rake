desc 'Scraping jobs at Laredo Medical Center'

task :scrape_laredo_medical_center => :environment do

  puts "********************************************"
  puts "***** SCRAPING Laredo Medical Center *****"
  puts "********************************************"

  agent = Mechanize.new
  url = "https://chs.taleo.net/careersection/10001/jobsearch.ftl?lang=en&organization=200000100"
  agent.get(url)

  agent.page.search()

  table = agent.page.search('table.contentlist')
  # puts table
  table.search('tr').each do |tr|
    puts
    # puts tr
    # puts
    title = tr.search('span.titlelink')
    puts title
  end

  test = Mechanize.new
  url = "https://chs.taleo.net/careersection/10001/jobsearch.ajax"
  test.post(url)

  puts test.page

end
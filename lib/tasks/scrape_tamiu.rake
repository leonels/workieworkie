desc 'Scraping jobs at TAMIU'

task :scrape_tamiu => :environment do

  puts "********************************************"
  puts "***** SCRAPING TAMIU *****"
  puts "********************************************"

  agent = Mechanize.new
  url = "https://employment.tamiu.edu/applicants/jsp/shared/search/SearchResults.jsp?time=1416596116296"
  # agent.pre_connect_hooks << lambda { |p|
  #   p[:request]['JSESSIONID'] = '8937CCB6E0536E11179757D3DC489A08.node1'
  # }

  page = agent.get(url)
  
  agent.cookie_jar.save_as "cookies.yml"

  # temp_jar = agent.cookie_jar
  # puts agent.cookies.count

  # agent.cookie_jar = temp_jar
  # agent.get(url)

  # headers = {"JSESSIONID" => '8937CCB6E0536E11179757D3DC489A08.node1'}
  # agent.get(
  #   url, 
  #   [], 
  #   nil, 
  #   headers
  # )

  table = agent.page.search('table table.tabUnselectedBG td.whiteBG table table table')
  puts table
  
  # table.search('tr').each do |tr|
  #   title = tr.search('span.titlelink')
  #   puts title
  # end

end
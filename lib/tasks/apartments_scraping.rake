desc 'Scraping apartments'

task :scrape_apartments => :environment do
  puts "***** SCRAPING APARTMENTS *****"

  apts = Mechanize.new
  url = "http://www.apartments.com/search/?query=San%20Antonio,%20TX"

  apts.get(url)

  apts.page.search('span[itemprop="name"]').each do |link|
    puts link.text.strip
  end
end
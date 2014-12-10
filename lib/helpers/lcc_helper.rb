module LccHelper

  def load_city_jobs
    agent = Mechanize.new
    url = "http://agency.governmentjobs.com/laredo/default.cfm"
    agent.get(url)

    jobs = parse_city_of_laredo agent, url
    
    jobs
  end

end
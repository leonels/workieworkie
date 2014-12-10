module TasksHelper

  # jobs param is supposed to be an array of links
  def find_duplicates(jobs)
    jobs.group_by { |e| e }.select { |k, v| v.size > 1 }.map(&:first)
  end

  # jobs param is supposed to be an array of links
  def delete_duplicate_jobs(jobs)
    jobs.each do |d|
      # since it's a duplicate, it usually returns
      # two jobs, so when we do job[1] we are deleting
      # just one of the two
      # TO-DO 'job' is probably not very descriptive, 
      # because it always holds more than one job
      # so think of a better variable/array name
      job = Job.where(link: d)
      job[1].destroy
    end
    puts "#{jobs.size} job(s) deleted because they are duplicates."
  end

  # jobs param is supposed to be an array of links
  def delete_jobs(jobs)
    jobs.each do |link|
      job = Job.where(link: link)
      # gotta do an each block because there might be more than one
      # job with the same link
      job.each do |j|
        j.destroy
      end
    end
    puts "#{jobs.size} job(s) deleted because they are no longer on target website."
  end

end
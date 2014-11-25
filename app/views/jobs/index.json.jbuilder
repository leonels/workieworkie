json.array!(@jobs) do |job|
  json.extract! job, :id, :title, :salary, :department, :link
  json.url job_url(job, format: :json)
end

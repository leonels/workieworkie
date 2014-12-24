class DashboardController < ApplicationController
  respond_to :html

  def index
    @jobs = Job.order('updated_at DESC')
    respond_with(@jobs)
  end
end

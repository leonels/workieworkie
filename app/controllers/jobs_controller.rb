class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  skip_before_filter :authenticate_user! , :only => [:index, :show]

  before_filter :set_title

  respond_to :html

  def index
    @jobs = Job.order('updated_at DESC')
    # respond_with(@jobs)
    respond_to do |format|
      format.html
      format.json { render :json => @jobs}
    end
  end

  def show
    set_title(@job.title)
    respond_with(@job)
  end

  def new
    @job = Job.new
    respond_with(@job)
  end

  def edit
  end

  def create
    @job = Job.new(job_params)
    @job.save
    respond_with(@job)
  end

  def update
    @job.update(job_params)
    respond_with(@job)
  end

  def destroy
    @job.destroy
    respond_with(@job)
  end

  private
    def set_job
      @job = Job.find(params[:id])
    end

    def job_params
      params.require(:job).permit(:title, :salary, :department, :link)
    end

    def set_title(page_title = 'Jobs in Laredo Texas')
      @page_title = page_title
    end
end

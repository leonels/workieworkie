class StaticController < ApplicationController

  skip_before_filter :authenticate_user! , :only => [:contact]

  before_filter :set_title

  def contact
    set_title('Post a job')
  end

  private

  def set_title(page_title = 'Jobs in Laredo Texas')
    @page_title = page_title
  end
end
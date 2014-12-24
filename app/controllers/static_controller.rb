class StaticController < ApplicationController

  skip_before_filter :authenticate_user! , :only => [:contact]

  def contact
  end
end

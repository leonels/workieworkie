class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :select_layout

  before_action :authenticate_user!

  private

  def select_layout
  	if devise_controller?
  		'devise'
  	elsif params[:controller] == 'jobs' and params[:action] == 'index'
  		'search'
  	else
  		'application'
  	end
  end
end

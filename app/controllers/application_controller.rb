class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :select_layout

  before_action :authenticate_user!

  private

  def select_layout
  	devise_controller? ? 'devise' : 'application'
  end
end

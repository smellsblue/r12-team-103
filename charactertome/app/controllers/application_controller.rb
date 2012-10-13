class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  def handle_unverified_request
    raise ActionController::InvalidAuthenticityToken.new
  end
end

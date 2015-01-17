class ApplicationController < ActionController::Base

private
  def token_or_authenticate!
    if params[:api_key] && params[:api_key].length > 0
      @current_user = User.find_by_api_key(params[:api_key])
    end

    if !@current_user
      authenticate_user!
      @current_user = current_user
    end
  end
end

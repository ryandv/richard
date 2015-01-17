class ApiController < ActionController::Base
  before_filter :authenticate_api_user!

private
  def authenticate_api_user!
    if current_user.nil? && params[:api_key] && params[:api_key].length > 0
      @current_user = User.find_by_api_key(params[:api_key])
    end
  end
end

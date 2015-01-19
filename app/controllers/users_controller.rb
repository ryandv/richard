class UsersController < ApplicationController
  before_action :authenticate_user!

  def reset_api_key
    current_user.update_attributes(api_key: ApiKeyGenerator.generate)
    render json: { apiKey: current_user.api_key }
  end

  def api_key
    render json: { apiKey: current_user.api_key }
  end
end
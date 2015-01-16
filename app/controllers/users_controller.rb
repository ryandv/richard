class UsersController < ApplicationController
  def index
    if current_user
      @users = User.order("status desc")
    else
      redirect_to new_user_session_path
    end
  end

  def users_json
    respond_to do |format|
      format.json { render json: serialize_users(User.all) }
    end
  end

  def reset_api_key
    if current_user
      current_user.update_attributes(api_key: ApiKeyGenerator.generate)
    end

    render text: current_user.api_key
  end

  def api_key
    render text: current_user.api_key
  end

private
  def serialize_users(users)
    users.map do |user|
      {
        current_user: self.current_user?(user),
        status: self.status,
        email: self.email
      }
    end.to_json
  end

  module ApiKeyGenerator
    extend self

    def generate
      SecureRandom.hex(26)
    end
  end
end
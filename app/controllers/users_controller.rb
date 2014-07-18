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
      format.json { render json: User.all_json(current_user).to_json }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :status, :name, :avatar_url)
  end

end
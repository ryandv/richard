class UsersController < ApplicationController

  def index
    if current_user
      @users = User.all
    else
      redirect_to new_user_session_path
    end
  end

  def start_waiting
    user = User.find(params[:id])
    user.update_attributes! :status => User::WAITING, :status_changed_at => Time.now
    redirect_to root_path
  end

  def stop_waiting
    user = User.find(params[:id])
    user.update_attributes! :status => User::IDLE, :status_changed_at => Time.now
    redirect_to root_path
  end

  def run_gorgon
    user = User.find(params[:id])
    user.update_attributes! :status => User::RUNNING, :status_changed_at => Time.now
    redirect_to root_path
  end
end

class UsersController < ApplicationController

  def index
    @users = User.all
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
end

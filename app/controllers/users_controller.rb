class UsersController < ApplicationController

  def index
    if current_user
      @users = User.order("status desc").order("status_changed_at")
    else
      redirect_to new_user_session_path
    end
  end

  def users_json
    respond_to do |format|
      format.json { render json: User.all_json(current_user).to_json }
    end
  end

  def start_waiting
    user = User.find(params[:id])
    user.update_attributes :status => User::WAITING, :status_changed_at => Time.now

    if user.errors.any?
      flash[:error] = user.errors.full_messages
    end

    redirect_to root_path
  end

  def stop_waiting
    user = User.find(params[:id])

    user.update_attributes :status => User::IDLE, :status_changed_at => Time.now

    if user.errors.any?
      flash[:error] = user.errors.full_messages
    end

    redirect_to root_path
  end

  def run_gorgon
    user = User.find(params[:id])
    user.update_attributes :status => User::RUNNING, :status_changed_at => Time.now

    if user.errors.any?
      flash[:error] = user.errors.full_messages
    else
      Gorgon.run(current_user.id)
    end

    redirect_to root_path
  end

  def finish_running
    user = User.find(params[:id])
    user.update_attributes :status => User::IDLE, :status_changed_at => Time.now

    if user.errors.any?
      flash[:error] = user.errors.full_messages
    else
      Gorgon.finish
    end

    redirect_to root_path
  end
end

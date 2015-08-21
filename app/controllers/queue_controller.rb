class QueueController < ApplicationController
  before_filter :token_or_authenticate!

  def index
    @queue_transactions = GorgonQueue.transactions.includes(:user)

    respond_to do |format|
      format.html { render 'index' }
      format.json { render 'index' }
    end
  end

  def grab
    do_transition do
      user = find_user
      GorgonQueue.grab(user)
    end
  end

  def release
    do_transition do
      user = find_user
      GorgonQueue.release(user)
    end
  end

  def force_release
    do_transition do
      user = User.find(params[:id])
      GorgonQueue.force_release(user)
    end
  end

  def status
    user = find_user
    @queue_transaction = GorgonQueue.transaction_for_user(user)

    respond_to do |format|
      format.json { render 'show' }
    end
  end

private

  def find_user
    if @current_user.integration?
      User.find_by_email(params[:email]) or raise GorgonQueue::TransitionException.new("Invalid user #{params[:email]}")
    else
      @current_user
    end
  end

  def do_transition(&block)
    yield

  rescue GorgonQueue::TransitionException => e
    flash[:error] = e.message

  ensure
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json do
        @queue_transactions = GorgonQueue.transactions.includes(:user)

        if flash[:error]
          render 'index', status: 422
        else
          render 'index'
        end
      end
    end
  end
end

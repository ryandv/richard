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
    do_transition { GorgonQueue.grab(@current_user) }
  end

  def release
    do_transition { GorgonQueue.release(@current_user) }
  end

  def force_release
    do_transition do
      user = User.find(params[:id])
      GorgonQueue.force_release(user)
    end
  end

  def status
    render json: { is_next_in_line: GorgonQueue.next_user == @current_user, blocking_duration: GorgonQueue.transaction_for_user(@current_user).try(:blocking_duration) }
  end

private

  def do_transition &block
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

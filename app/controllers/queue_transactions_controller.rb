class QueueTransactionsController < ApplicationController
  before_filter :token_or_authenticate!

  def index
    @queue_transactions = QueueTransaction.unfinished_transactions.includes(:user)

    respond_to do |format|
      format.html { render 'index' }
      format.json { render 'index' }
    end
  end

  def create
    QueueTransactionService.enqueue(@current_user)
  rescue QueueTransactionService::TransitionException => e
    flash[:error] = e.message
  ensure
    respond_with_queue
  end

  def cancel
    QueueTransactionService.cancel(@current_user)
  rescue QueueTransactionService::TransitionException => e
    flash[:error] = e.message
  ensure
    respond_with_queue
  end

  def run
    QueueTransactionService.run(@current_user)
  rescue QueueTransactionService::TransitionException => e
    flash[:error] = e.message
  ensure
    respond_with_queue
  end

  def finish
    QueueTransactionService.finish(@current_user)
  rescue QueueTransactionService::TransitionException => e
    flash[:error] = e.message
  ensure
    respond_with_queue
  end

  def force_release
    user = User.find(params[:id])
    QueueTransactionService.force_release(user)
  rescue QueueTransactionService::TransitionException => e
    flash[:error] = e.message
  ensure
    respond_with_queue
  end

  def pending_next
    if QueueTransaction.next_for_user(@current_user).try(:status) == QueueTransaction::PENDING
      next_in_line = true
    else
      next_in_line = false
    end

    render json: { next_in_line: next_in_line }
  end

private
  def respond_with_queue
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json do
        @queue_transactions = QueueTransaction.unfinished_transactions.includes(:user)
        render 'index'
      end
    end
  end
end

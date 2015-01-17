class QueueTransactionsController < ApplicationController
  before_filter :token_or_authenticate!

  def index
    respond_with_queue
  end

  def create
    QueueTransactionService.enqueue(@current_user)
  rescue QueueTransactionService::TransitionException => e
    flash[:error] = e.message
  ensure
    respond_with_queue
  end

  def cancel
    QueueTransactionService.cancel(load_queue_transaction)
    respond_with_queue
  end

  def run
    QueueTransactionService.run(load_queue_transaction)
    respond_with_queue
  end

  def finish
    QueueTransactionService.finish(load_queue_transaction)
    respond_with_queue
  end

  def force_release
    QueueTransactionService.force_release(load_queue_transaction)
    respond_with_queue
  end

  def pending_next
    if @current_user.current_queue_transaction.try(:status) == QueueTransaction::PENDING
      next_in_line = true
    else
      next_in_line = false
    end

    render json: { next_in_line: next_in_line }
  end

private
  def respond_with_queue
    @queue_transactions = QueueTransaction.unfinished_transactions.includes(:user)

    respond_to do |format|
      format.html { render 'index' }
      format.json { render 'index' }
    end
  end

  def load_queue_transaction
    @queue_transaction = QueueTransaction.find(params[:id])
  end

  def token_or_authenticate!
    if params[:api_key] && params[:api_key].length > 0
      @current_user = User.find_by_api_key(params[:api_key])
    end

    if !@current_user
      authenticate_user!
      @current_user = current_user
    end
  end
end

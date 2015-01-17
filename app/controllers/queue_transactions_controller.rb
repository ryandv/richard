class QueueTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_filter :check_if_api_user

  def index
    @queue = QueueTransaction.unfinished_transactions.load
  end

  def create
    QueueTransactionService.enqueue(@current_user)
    validate_user
    redirect_to root_path
  end

  def cancel
    QueueTransactionService.cancel(load_queue_transaction)
    validate_user
    redirect_to root_path
  end

  def run
    QueueTransactionService.run(load_queue_transaction)
    validate_user
    redirect_to root_path
  end

  def finish
    QueueTransactionService.finish(load_queue_transaction)
    validate_user
    redirect_to root_path
  end

  def pending_next
    if @current_user.current_queue_transaction.try(:status) == QueueTransaction::PENDING
      next_in_line = true
    else
      next_in_line = false
    end

    render json: { next_in_line: next_in_line }
  end

  def force_release
    QueueTransactionService.force_release(load_queue_transaction)

    redirect_to root_path
  end

private
  def load_queue_transaction
    @queue_transaction = QueueTransaction.find(params[:id])
  end

  def check_if_api_user
    if current_user.nil? && params[:api_key] && params[:api_key].length > 0
      @current_user = User.find_by_api_key(params[:api_key])
    else
      @current_user = current_user
    end
  end

  def validate_user
    if @current_user.errors.any?
      flash[:error] = @current_user.errors.full_messages
    end
  end
end

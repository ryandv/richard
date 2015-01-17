module Api
  class QueueTransactionsController < ApiController
    def index
      @transactions = QueueTransaction.unfinished_transactions.load
    end

    def enqueue
      QueueTransactionService.enqueue(@current_user)
      redirect_to root_url
    end

    def cancel
      QueueTransactionService.cancel(load_queue_transaction)
      redirect_to root_url
    end

    def run
      QueueTransactionService.run(load_queue_transaction)
      redirect_to root_url
    end

    def finish
      QueueTransactionService.finish(load_queue_transaction)
      redirect_to root_url
    end

    def force_release
      QueueTransactionService.force_release(load_queue_transaction)
      redirect_to root_url
    end

  private
    def load_queue_transaction
      @queue_transaction = QueueTransaction.find(params[:id])
    end
  end
end
module GorgonQueue
  module Queries
    def transactions
      QueueTransaction.where(finished_at: nil).order("waiting_start_at asc")
    end

    def users
      transactions.includes(:user).map(&:user)
    end

    def transactions_before(queue_transaction = nil)
      if queue_transaction.nil?
        transactions
      else
        transactions.where("id < :id", id: queue_transaction.id)
      end
    end

    def size
      transactions.count
    end

    def transaction_for_user(user)
      transactions.where(user: user).first
    end

    def user_enqueued?(user)
      transaction_for_user(user).present?
    end

    def next_transaction
      transactions.first
    end

    def next_user
      next_transaction.try(:user)
    end
  end
end

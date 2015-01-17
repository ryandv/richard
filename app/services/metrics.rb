module Metrics
  extend self

  def wait_time(user)
    queue_transaction = user.try(:current_queue_transaction)
    queue_size = QueueTransaction.queue_size
    next_transaction = QueueTransaction.first_in_queue

    if queue_size == 0
      0
    else
      [0, QueueTransaction.average_run_time * QueueTransaction.number_transactions_before(queue_transaction) - next_transaction.blocking_duration].max
    end
  end
end
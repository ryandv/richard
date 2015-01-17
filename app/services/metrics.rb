module Metrics
  extend self

  def wait_time(user)
    queue_transaction = QueueTransaction.next_for_user(user)
    queue_size = QueueTransaction.queue_size
    next_transaction = QueueTransaction.first_in_queue

    if queue_size == 0
      0
    else
      [0, QueueTransaction.average_run_time * QueueTransaction.number_transactions_before(queue_transaction) - next_transaction.blocking_duration].max
    end
  end
end
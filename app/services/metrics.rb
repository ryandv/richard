module Metrics
  extend self

  def wait_time(current_user)
    queue_transaction = current_user ? current_user.current_queue_transaction : nil
    queue_size = QueueTransaction.queue_size
    first_in_queue = QueueTransaction.get_first_in_queue

    if queue_size == 0
      0
    elsif queue_size == 1
      [0,QueueTransaction.average_run_time - first_in_queue.blocking_duration].max
    else
      [0, QueueTransaction.average_run_time * QueueTransaction.number_transactions_before(queue_transaction) - first_in_queue.blocking_duration].max
    end
  end
end
module GorgonQueue
  module Metrics
    def wait_time(user)
      queue_transaction = GorgonQueue.transaction_for_user(user)
      transaction = GorgonQueue.next_transaction

      if GorgonQueue.size == 0
        0
      else
        [0, GorgonQueue.average_run_time * GorgonQueue.transactions_before(queue_transaction).count - transaction.blocking_duration].max
      end
    end

    def average_run_time
      sql = <<-SQL
        SELECT
          extract(epoch FROM avg(finished_at - waiting_start_at)) AS average_run_time
        FROM queue_transactions
        WHERE
          finished_at IS NOT NULL AND
          extract(epoch FROM (finished_at - running_start_at)) < (
            SELECT stddev(extract (epoch FROM (finished_at - running_start_at)))
          FROM queue_transactions)
        AND finished_at - running_start_at > interval '3 minute'
      SQL

      QueueTransaction.find_by_sql(sql).first["average_run_time"].to_f
    end
  end
end

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
        select extract(epoch from avg(finished_at - pending_start_at)) as average_run_time
        from queue_transactions
        where is_complete = true and finished_at is not null and
          extract(epoch from (finished_at - pending_start_at)) < (
            select stddev(extract (epoch from (finished_at - pending_start_at)))
          from queue_transactions)
        and finished_at - pending_start_at > interval '3 minute'
      SQL

      QueueTransaction.find_by_sql(sql).first["average_run_time"].to_f
    end
  end
end
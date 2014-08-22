class AddStatusToOldTransactions < ActiveRecord::Migration
  def change
    execute <<-SQL
      update queue_transactions set status = '#{QueueTransaction::COMPLETE}' where status is null
    SQL
  end
end

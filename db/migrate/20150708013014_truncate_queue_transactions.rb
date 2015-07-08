class TruncateQueueTransactions < ActiveRecord::Migration
  def change
    QueueTransaction.delete_all
  end
end

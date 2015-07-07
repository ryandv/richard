class SimplifyStates < ActiveRecord::Migration
  def change
    remove_column :queue_transactions, :pending_start_at
    remove_column :queue_transactions, :cancelled_at
    remove_column :queue_transactions, :is_complete
  end
end

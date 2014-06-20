class CreateQueueTransactions < ActiveRecord::Migration
  def change
    create_table(:queue_transactions) do |t|
      t.integer :user_id
      t.datetime :waiting_start_at
      t.datetime :pending_start_at
      t.datetime :running_start_at
      t.datetime :finished_at
      t.datetime :cancelled_at
      t.boolean :is_complete, :default => false

      t.timestamps
    end

  end
end

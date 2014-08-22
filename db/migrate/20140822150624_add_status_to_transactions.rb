class AddStatusToTransactions < ActiveRecord::Migration
  def change
    add_column :queue_transactions, :status, :string
  end
end

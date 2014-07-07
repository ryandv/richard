class AddForceReleaseAtToQueueTransaction < ActiveRecord::Migration
  def change
    add_column :queue_transactions, :force_release_at, :datetime
  end
end

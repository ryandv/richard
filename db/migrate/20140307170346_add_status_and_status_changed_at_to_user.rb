class AddStatusAndStatusChangedAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :status, :integer, :null => false, :default => 0
    add_column :users, :status_changed_at, :datetime
  end
end

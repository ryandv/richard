class CleanUserUp < ActiveRecord::Migration
  def up
    remove_column :users, :status
    remove_column :users, :status_changed_at
    add_column :users, :status, :string, :default => "idle"
    add_column :users, :name, :string
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :uid
    remove_column :users, :provider
    add_column :users, :avatar_url, :string
  end

  def down
  end
end

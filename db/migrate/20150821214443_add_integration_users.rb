class AddIntegrationUsers < ActiveRecord::Migration
  def change
    add_column :users, :integration, :boolean, default: false
  end
end

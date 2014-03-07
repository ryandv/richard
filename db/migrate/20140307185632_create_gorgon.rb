class CreateGorgon < ActiveRecord::Migration
  def up
    create_table :gorgon
    add_column :gorgon, :status, :integer
    add_column :gorgon, :user_id, :integer
  end

  def down
    drop_table :gorgon
  end
end

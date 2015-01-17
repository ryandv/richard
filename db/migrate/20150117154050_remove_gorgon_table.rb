class RemoveGorgonTable < ActiveRecord::Migration
  def change
    drop_table :gorgon
  end
end

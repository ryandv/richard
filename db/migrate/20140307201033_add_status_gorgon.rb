class AddStatusGorgon < ActiveRecord::Migration
  def up
    Gorgon.create(status: 1)
  end

  def down
  end
end

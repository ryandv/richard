class AddStatusGorgon < ActiveRecord::Migration
  def up
    Gorgon.create(status: 0)
  end

  def down
  end
end

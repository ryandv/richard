class SetFinishedAt < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE queue_transactions
      SET finished_at = updated_at
      WHERE finished_at IS NULL
    SQL
  end
end

class Gorgon < ActiveRecord::Base

  # attr_accessible :status, :user_id

  RUNNING = 0
  AVAILABLE = 1

  MAP = { RUNNING => 'Running', AVAILABLE => 'Available' }

  def self.status
    Gorgon.all.first.status
  end

  def self.run(user_id)
    Gorgon.all.first.update_attributes! status: RUNNING, user_id: user_id
  end

  def self.finish()
    # Gorgon.all.first.update_attributes! status: AVAILABLE, user_id: nil
  end

  def self.running_user_id
    Gorgon.all.first.user_id
  end

  def self.free?
    Gorgon.status == AVAILABLE
  end
end

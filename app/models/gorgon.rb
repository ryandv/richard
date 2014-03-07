class Gorgon < ActiveRecord::Base

  attr_accessible :status, :user_id

  RUNNING = 0
  AVAILABLE = 1

  MAP = { RUNNING => 'Running', AVAILABLE => 'Available' }

  def self.status
    Gorgon.all.first.status
  end

  def self.run
    Gorgon.all.first.update_attributes! status: RUNNING
  end

  def self.finish
    Gorgon.all.first.update_attributes! status: AVAILABLE
  end
end

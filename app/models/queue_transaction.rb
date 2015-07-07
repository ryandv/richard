class QueueTransaction < ActiveRecord::Base
  belongs_to :user

  WAITING = "waiting"
  RUNNING = "running"
  RELEASED = "released"

  def duration
    if waiting?
      Time.now - waiting_start_at
    elsif running?
      Time.now - running_start_at
    end
  end

  def blocking_duration
    if waiting?
      nil
    else
      Time.now - running_start_at
    end
  end

  def waiting?
    status == WAITING
  end

  def running?
    status == RUNNING
  end

  def released?
    status == RELEASED
  end

  def status
    return RELEASED if finished_at
    return WAITING if running_start_at.nil?

    return RUNNING
  end
end

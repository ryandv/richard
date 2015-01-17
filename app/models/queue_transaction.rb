class QueueTransaction < ActiveRecord::Base
  belongs_to :user

  WAITING = "waiting"
  PENDING = "pending"
  RUNNING = "running"
  CANCELLED = "cancelled"
  COMPLETE = "complete"

  STATUS_MAP = {
    WAITING => "Waiting",
    PENDING => "Pending Start",
    RUNNING => "Running"
  }

  def duration
    if waiting?
      Time.now - waiting_start_at
    elsif pending?
      Time.now - pending_start_at
    elsif running?
      Time.now - running_start_at
    end
  end

  def blocking_duration
    if waiting?
      nil
    else
      Time.now - pending_start_at
    end
  end

  def waiting?
    status == WAITING
  end

  def pending?
    status == PENDING
  end

  def running?
    status == RUNNING
  end

  def status
    return CANCELLED if cancelled_at
    return COMPLETE if finished_at

    if pending_start_at.nil?
      WAITING
    elsif running_start_at.nil?
      PENDING
    elsif finished_at.nil?
      RUNNING
    end
  end
end
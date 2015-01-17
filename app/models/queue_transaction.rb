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

  scope :unfinished_transactions, -> { where(is_complete: false).order("waiting_start_at asc") }

  def self.average_run_time
    sql = <<-SQL
      select extract(epoch from avg(finished_at - pending_start_at)) as average_run_time
      from queue_transactions
      where is_complete = true and finished_at is not null and
        extract(epoch from (finished_at - pending_start_at)) < (
          select stddev(extract (epoch from (finished_at - pending_start_at)))
        from queue_transactions)
      and finished_at - pending_start_at > interval '3 minute'
    SQL

    QueueTransaction.find_by_sql(sql).first["average_run_time"].to_f
  end

  def self.number_transactions_before(queue_transaction = nil)
    if queue_transaction.nil?
      QueueTransaction.where(is_complete: false).count
    else
      QueueTransaction.where("id < :id and is_complete = false", {id: queue_transaction.id}).count
    end
  end

  def self.queue_size
    QueueTransaction.where(is_complete: false).count
  end

  def self.first_in_queue
    QueueTransaction.where(is_complete: false).order("waiting_start_at asc").first
  end

  def self.user_enqueued?(user)
    next_for_user(user).present?
  end

  def self.next_for_user(user)
    unfinished_transactions.where(user: user).first
  end

  def self.first_user_in_queue
    first_in_queue.user
  end

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
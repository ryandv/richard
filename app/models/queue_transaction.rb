class QueueTransaction < ActiveRecord::Base
  belongs_to :user

  attr_accessible :waiting_start_at, :pending_start_at, :running_start_at, :user_id, :finished_at, :cancelled_at, :is_complete

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


  def self.average_run_time
    sql =<<-SQL
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

  def self.number_transactions_before(queue_transaction)
    if queue_transaction.nil?
      QueueTransaction.where(:is_complete => false).count
    else
      QueueTransaction.where("id < :id and is_complete = false", {:id => queue_transaction.id}).count
    end
  end

  def self.queue_size
    QueueTransaction.where(:is_complete => false).count
  end

  def self.get_next_in_queue(transaction)
    QueueTransaction.where("is_complete = false and id > :id", {:id => transaction.id}).order("waiting_start_at asc").first
  end

  def self.get_first_in_queue
    QueueTransaction.where(:is_complete => false).order("waiting_start_at asc").first
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

=begin
  def validate_transition
     retval = self.changes[:status] == [IDLE, WAITING]\
       || ( self.changes[:status] == [WAITING, RUNNING] && Gorgon.status == Gorgon::AVAILABLE )  && self.id == User.next_user.id \
       || self.changes[:status] == [RUNNING, IDLE] || self.changes[:status] == [WAITING, IDLE]\
       || self.changes[:status] == [IDLE, RUNNING]

    self.errors.add(:base, "Not a valid transition Mr Nixon") unless retval
  end
=end
end
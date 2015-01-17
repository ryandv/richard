module QueueTransactionService
  extend self

  def enqueue(user)
    if QueueTransaction.user_enqueued?(user)
      raise TransitionException.new("You are already enqueued")
    end

    if QueueTransaction.first_in_queue.nil?
      now = Time.now

      QueueTransaction.create(
        user_id: user.id,
        waiting_start_at: now,
        pending_start_at: now,
        running_start_at: now,
        is_complete: false
      )
    else
      QueueTransaction.create(
        user_id: user.id,
        waiting_start_at: Time.now,
        is_complete: false
      )
    end
  end

  def run(queue_transaction)
    queue_transaction.update_attributes(running_start_at: Time.now)
  end

  def cancel(queue_transaction)
    queue_transaction.update_attributes(
      cancelled_at: Time.now,
      is_complete: true
    )

    start_next_transaction
  end

  def finish(queue_transaction)
    queue_transaction.update_attributes(
      finished_at: Time.now,
      is_complete: true
    )

    start_next_transaction
  end

  def force_release(queue_transaction)
    queue_transaction.update_attributes(
      force_release_at: Time.now,
      is_complete: true
    )

    UserMailer.notify_release(queue_transaction)

    start_next_transaction
  end

private

  def start_next_transaction
    next_transaction = QueueTransaction.first_in_queue

    if next_transaction
      next_transaction.update_attributes(pending_start_at: Time.now)
      UserMailer.notify_user_of_turn(next_transaction)
    end
  end

  class TransitionException < RuntimeError; end
end
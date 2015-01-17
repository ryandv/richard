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

  def run(user)
    if QueueTransaction.first_user_in_queue != user
      raise TransitionException.new("You are not next in line")
    end

    queue_transaction = QueueTransaction.next_for_user(user)
    queue_transaction.update_attributes(running_start_at: Time.now)
  end

  def cancel(user)
    if !QueueTransaction.user_enqueued?(user)
      raise TransitionException.new("You are not enqueued")
    end

    queue_transaction = QueueTransaction.next_for_user(user)
    queue_transaction.update_attributes(
      cancelled_at: Time.now,
      is_complete: true
    )

    start_next_transaction
  end

  def finish(user)
    if !QueueTransaction.user_enqueued?(user)
      raise TransitionException.new("You are not enqueued")
    end

    if QueueTransaction.first_user_in_queue != user
      raise TransitionException.new("It is not your turn")
    end

    queue_transaction = QueueTransaction.next_for_user(user)
    queue_transaction.update_attributes(
      finished_at: Time.now,
      is_complete: true
    )

    start_next_transaction
  end

  def force_release(user)
    if !QueueTransaction.user_enqueued?(user)
      raise TransitionException.new("This person is no longer enqueued")
    end

    if QueueTransaction.first_user_in_queue != user
      raise TransitionException.new("This person is not first in the queue")
    end

    queue_transaction = QueueTransaction.next_for_user(user)
    queue_transaction.update_attributes(
      force_release_at: Time.now,
      is_complete: true
    )

    UserMailer.notify_release(user)

    start_next_transaction
  end

private

  def start_next_transaction
    next_transaction = QueueTransaction.first_in_queue

    if next_transaction
      next_transaction.update_attributes(pending_start_at: Time.now)
      UserMailer.notify_user_of_turn(next_transaction.user)
    end
  end

  class TransitionException < RuntimeError; end
end
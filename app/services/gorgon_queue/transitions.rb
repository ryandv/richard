module GorgonQueue
  module Transitions
    def enqueue(user)
      if GorgonQueue.user_enqueued?(user)
        raise TransitionException.new("You are already enqueued")
      end

      if GorgonQueue.next_transaction.nil?
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
      if GorgonQueue.next_user != user
        raise TransitionException.new("You are not next in line")
      end

      queue_transaction = GorgonQueue.transaction_for_user(user)
      queue_transaction.update_attributes(running_start_at: Time.now)
    end

    def cancel(user)
      if !GorgonQueue.user_enqueued?(user)
        raise TransitionException.new("You are not enqueued")
      end

      queue_transaction = GorgonQueue.transaction_for_user(user)
      queue_transaction.update_attributes(
        cancelled_at: Time.now,
        is_complete: true
      )

      start_next_transaction
    end

    def finish(user)
      if !GorgonQueue.user_enqueued?(user)
        raise TransitionException.new("You are not enqueued")
      end

      if GorgonQueue.next_user != user
        raise TransitionException.new("It is not your turn")
      end

      queue_transaction = GorgonQueue.transaction_for_user(user)
      queue_transaction.update_attributes(
        finished_at: Time.now,
        is_complete: true
      )

      start_next_transaction
    end

    def force_release(user)
      if !GorgonQueue.user_enqueued?(user)
        raise TransitionException.new("This person is no longer enqueued")
      end

      if GorgonQueue.next_user != user
        raise TransitionException.new("This person is not first in the queue")
      end

      queue_transaction = GorgonQueue.transaction_for_user(user)
      queue_transaction.update_attributes(
        force_release_at: Time.now,
        is_complete: true
      )

      UserMailer.notify_release(user)

      start_next_transaction
    end

  private

    def start_next_transaction
      next_transaction = GorgonQueue.next_transaction

      if next_transaction
        next_transaction.update_attributes(pending_start_at: Time.now)
        UserMailer.notify_user_of_turn(next_transaction.user)
      end
    end
  end
end
module QueueHogger
  extend self

  def check
    transaction = GorgonQueue.next_transaction

    if transaction.try(:pending?) &&
        transaction.duration > 20.minutes &&
        transaction.duration < 21.minutes

      notify(transaction.user)
    end
  end

  def notify(user)
    UserMailer.notify_hog(user)
  end
end
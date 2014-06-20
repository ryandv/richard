class UserMailer < ActionMailer::Base
  default from: "richard@nulogy.com"

  def notify_next_in_line
    next_transaction = QueueTransaction.get_next_in_line
    if next_transaction
      user = next_transaction.user
      subject = "#{Time.now.strftime("%H:%M")} - Gorgon is free!"
      mail(to: "#{user.email}", subject: subject).deliver
    end
  end

  def notify_hog(user, waiter)
    subject = "Are you still running Gorgon?"
    # #{pluralize(waiter.count, 'person')}
    if waiter.count > 0
      subject << " - #{waiter.count}  are waiting."
    end
    mail(to: "#{user.email}", subject: subject).deliver
  end
end
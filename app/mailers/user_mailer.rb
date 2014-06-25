class UserMailer < ActionMailer::Base
  default from: "richard@nulogy.com"

  def notify_user_of_turn(transaction)
    user = transaction.user
    subject = "Gorgon is free! (#{Time.now.strftime("%H:%M")})"
    mail(to: "#{user.email}", subject: subject).deliver
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
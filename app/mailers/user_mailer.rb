class UserMailer < ActionMailer::Base
  default from: "richard@nulogy.com"

  def notify_user_of_turn(transaction)
    user = transaction.user
    subject = "Gorgon is free! (#{Time.now.strftime("%H:%M")})"
    send_email(user.email, subject)
  end

  def notify_hog(transaction)
    user = transaction.user
    subject = "Are you still running Gorgon?"
    send_email(user.email, subject)
  end

  def notify_release(transaction)
    user = transaction.user
    subject = "You have been force released at #{Time.now.strftime("%H:%M")}"
    send_email(user.email, subject)
  end

  private
  def send_email(address, subject)
    mail(to: "#{address}", subject: subject).deliver
  end
end
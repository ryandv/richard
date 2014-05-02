class UserMailer < ActionMailer::Base
  default from: "thedude@gmail.com"

  def notify_next_in_line
    user = User.where(status: User::WAITING).order(updated_at: :desc).first

    subject = "Get Gorgoning! and be quick!"

    #mail(to: "robertofdooley@gmail.com", subject: subject).deliver
    mail(to: "#{user.email}", subject: subject, body: "corpse").deliver if user
  end
end

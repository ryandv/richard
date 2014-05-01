class UserMailer < ActionMailer::Base
  default from: "thedude@gmail.com"

  def notify_next_in_line
    #user = User.where(status: User::WAITING).order(updated_at: :desc).first

    subject = "Gorgon is free: You're up!"
    mail(to: "robertofdooley@gmail.com", subject: subject).deliver
  end
end

class UserMailer < ActionMailer::Base
  default from: "richard@nulogy.com"


  def notify_next_in_line
    user = User.where(status: User::WAITING).order(updated_at: :desc).first

    subject = "Gorgon is free!"

    mail(to: "#{user.email}", subject: subject).deliver if user
  end
end

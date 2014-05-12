class UserMailer < ActionMailer::Base
  default from: "richard@nulogy.com"


  def notify_next_in_line
    user = User.where(status: User::WAITING).order(updated_at: :desc).first

    subject = "Gorgon is free!"

    mail(to: "#{user.email}", subject: subject).deliver if user
  end

  def test_email
    mail(to: "robertd@nulogy.com", subject: "lots of stuff").deliver
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
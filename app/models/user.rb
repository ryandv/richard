class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable, :rememberable, :trackable, :validatable, omniauth_providers: [:google_oauth2]

  def current_queue_transaction
    QueueTransaction.where(user_id: id, is_complete: false).first
  end

  def current_user?(current_user)
    current_user.id == self.id
  end

  def self.runner_hogging
    transaction = QueueTransaction.get_first_in_queue
    pending_for = Time.now - transaction.pending_start_at

    if transaction && pending_for > 60*20 && pending_for < 60*21
      UserMailer.notify_hog(transaction)
    end
  end
end

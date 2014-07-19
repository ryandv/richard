class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable,
         :rememberable, :trackable, :validatable, :omniauth_providers => [:google_oauth2]

  validate :validate_transition, on: :update

  def self.from_omniauth(auth)
    user = User.find_by_email(auth.info.email)
    unless user
      user = User.create\
        :name => auth.info.name,
        :email => auth.info.email,
        :password => Devise.friendly_token[0,20],
        :avatar_url => auth.info.image
    end
    user
  end

  def current_queue_transaction
    QueueTransaction.where(:user_id => id, :is_complete => false).first
  end

  def hashify(current_user)
    {

      :current_user => self.current_user?(current_user),
      :status => self.status,
      :email => self.email
    }
  end

  def current_user?(current_user)
    current_user.id == self.id
  end

  def self.all_json(current_user)
    User.all.map {|u| u.hashify(current_user) }
  end

  def self.runner_hogging
    transaction = QueueTransaction.get_first_in_queue
    user = User.where(id: transaction.user_id).first
    pending_for = Time.now - transaction.pending_start_at

    if transaction && pending_for > 60*20 && pending_for < 60*21
      UserMailer.notify_hog(user)
    end
  end
end

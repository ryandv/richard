class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable,
         :rememberable, :trackable, :validatable, :omniauth_providers => [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :status, :name, :avatar_url

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

  def running_too_long?
    puts "running too long"
    puts Gorgon.running_user_id == self.id && Time.now - self.status_changed_at > 2.minutes
    #current_user.id == Gorgon.running_user_id && current_user.running_too_long?
    Gorgon.running_user_id == self.id && Time.now - self.status_changed_at > 2.minutes
  end

  def self.runner_hogging
    puts 'hogging'
    UserMailer.test_email

    user = Gorgon.running_user_id
    if user
      over_too_long = (Gorgon.running_user_id == self.id) && (Time.now - self.status_changed_at > 20.minutes)
      waiters = User.where(status: WAITING).count
      if over_too_long
        notify_hog(user, waiters)
      end
    end
  end
end

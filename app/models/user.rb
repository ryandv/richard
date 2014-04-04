class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :provider, :uid, :avatar, :status, :status_changed_at

  validate :validate_transition, on: :update


  IDLE = 0
  WAITING = 1
  RUNNING = 2

  STATUS_MAP = {
    IDLE => "Idle",
    WAITING => "Waiting",
    RUNNING => "Running"
  }

  def self.from_omniauth(auth)
    if user = User.find_by_email(auth.info.email)
      user.provider = auth.provider
      user.uid = auth.uid
      user
    else
      where(auth.slice(:provider, :uid)).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
      end
    end
  end

  def waiting?
    self.status == WAITING
  end

  def running?
    self.status == RUNNING
  end

  def self.next_user
    User.where(:status => User::WAITING).order("status_changed_at").first
  end

  def self.gorgon_free?
    User.where(:status => RUNNING).empty?
  end

  def running_too_long?
    Time.now - self.status_changed_at > 2.minutes
  end

  def validate_transition
     retval = self.changes[:status] == [IDLE, WAITING]\
       || ( self.changes[:status] == [WAITING, RUNNING] && Gorgon.status == Gorgon::AVAILABLE )  && self.id == User.next_user.id \
       || self.changes[:status] == [RUNNING, IDLE] || self.changes[:status] == [WAITING, IDLE]

    puts self.changes[:status]
    self.errors.add(:base, "Not a valid transition Mr Nixon") unless retval
     puts self.errors.inspect
    #retval
  end
end

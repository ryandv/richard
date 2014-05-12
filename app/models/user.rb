class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :provider, :uid, :avatar, :status, :status_changed_at

  validate :validate_transition, on: :update

  after_update :notify_next_in_line

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

  def hashify(current_user)
    {
      :status_changed_at => self.status_changed_at,
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

  def waiting?
    self.status == WAITING
  end

  def running?
    #self.status == RUNNING
    Gorgon.where(status: 0).where(user_id: self.id).count > 0
  end

  def self.next_user
    User.where(:status => User::WAITING).order("status_changed_at").first
  end

  def self.gorgon_free?
    #User.where(:status => RUNNING).empty?
    Gorgon.where(status: 1).count > 0
  end

  def running_too_long?
    puts "running too long"
    puts Gorgon.running_user_id == self.id && Time.now - self.status_changed_at > 2.minutes
    #current_user.id == Gorgon.running_user_id && current_user.running_too_long?
    Gorgon.running_user_id == self.id && Time.now - self.status_changed_at > 2.minutes
  end

  def validate_transition
     retval = self.changes[:status] == [IDLE, WAITING]\
       || ( self.changes[:status] == [WAITING, RUNNING] && Gorgon.status == Gorgon::AVAILABLE )  && self.id == User.next_user.id \
       || self.changes[:status] == [RUNNING, IDLE] || self.changes[:status] == [WAITING, IDLE]\
       || self.changes[:status] == [IDLE, RUNNING]

    self.errors.add(:base, "Not a valid transition Mr Nixon") unless retval
  end

  def notify_next_in_line
    # notify when someone leaves q
    # notify when someone finishes ...

    UserMailer.notify_next_in_line if Gorgon.free?
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

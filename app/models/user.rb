class User < ActiveRecord::Base

  devise :database_authenticatable, :omniauthable,
    :rememberable, :trackable, :validatable, omniauth_providers: [:google_oauth2]
end

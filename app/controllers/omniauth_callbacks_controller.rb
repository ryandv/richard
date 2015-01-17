class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user = find_or_create_user(request.env["omniauth.auth"])

    if user.persisted?
      flash.notice = "Signed in Through Google!"
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      flash.notice = "You are almost Done! Please provide a password to finish setting up your account"
      redirect_to new_user_registration_url
    end
  end

private
  def find_or_create_user(omniauth)
    user = User.find_by_email(omniauth.info.email)

    unless user
      user = User.create(
        name: omniauth.info.name,
        email: omniauth.info.email,
        password: Devise.friendly_token[0,20],
        avatar_url: omniauth.info.image
      )
    end

    return user
  end
end

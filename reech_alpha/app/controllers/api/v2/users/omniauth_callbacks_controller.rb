class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook

    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])

    if @user and @user.persisted?
      sign_in @user, :event => :authentication
      cookies[:user_id] = nil
      cookies[:user_id] = @user.id
    end
    render nothing: true
  end

  def failure
    render nothing: true
  end
end

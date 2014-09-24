module Api
	module V2
		class RegistrationsController < DeviseController
			def update
				@user = User.find(current_user.id)
  email_changed = @user.email != params[:user][:email]
  password_changed = !params[:user][:password].empty?
  successfully_updated = if email_changed or password_changed
    @user.update_with_password(params[:user])
  else
    @user.update_without_password(params[:user])
  end

  if successfully_updated
    # Sign in the user bypassing validation in case his password changed
    sign_in @user, :bypass => true
    //need to call action here
  else
   	render :nothing => true
			end
		end
	end
end

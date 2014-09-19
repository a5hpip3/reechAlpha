module Api
	module V2
		class SessionsController < 	BaseController

			def create
				user_session = UserSession.new(params[:session][:user_details])
				if user_session.save
					user = User.where(phone_number: user_session.phone_number).first
					api_key = ::ApiKey.find_or_create_by_user_id(user.reecher_id).access_token
					render json: {user: user, user_profile: user.user_profile, api_key: api_key}
				else
					render json: user_session.errors
				end

			end

		end
	end
end

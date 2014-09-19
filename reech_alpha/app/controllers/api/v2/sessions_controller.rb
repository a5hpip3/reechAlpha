module Api
	module V2
		class SessionsController < 	BaseController

			def create
				user_session = UserSession.new(params[:session][:user_details])
				if user_session.save
					render json: {current_user: current_user}
				else
					render status: 401, json: {errors: user_session.errors}
				end
			end

		end
	end
end

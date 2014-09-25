module Api
	module V2
		class NotificationsController < BaseController
			before_filter :require_current_user

			def index
				render json: current_user.notifications.limit(20).as_json
			end

		end
	end
end

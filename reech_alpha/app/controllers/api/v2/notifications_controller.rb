module Api
	module V2
		class NotificationsController < BaseController
			before_filter :require_current_user

			def index
				render json: current_user.notifications.order('created_at DESC').page(params[:page].to_i).per_page(params[:per_page].to_i).as_json
			end

		end
	end
end

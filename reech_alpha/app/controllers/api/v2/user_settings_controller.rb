module Api
	module V2
		class UserSettingsController < BaseController
			before_filter :require_current_user
			@model_class = UserSettings
			def new
				render json: current_user.user_settings || UserSettings.new
			end
		end
	end
end
